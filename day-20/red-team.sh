#!/usr/bin/env bash

set -euo pipefail

NS="${NS:-prod-zt}"
ATTACKER_NS="${ATTACKER_NS:-attacker-ns}"
PLAIN_NS="${PLAIN_NS:-plain-attacker}"
AWS_REGION="${AWS_REGION:-us-east-1}"
ECR_REGISTRY="${ECR_REGISTRY:-711387135481.dkr.ecr.us-east-1.amazonaws.com}"
IMAGE_REPO="${IMAGE_REPO:-bootcamp-api}"
SIGNED_TAG="${SIGNED_TAG:-$(git rev-parse HEAD)}"
UNSIGNED_TAG="${UNSIGNED_TAG:-unsigned}"
VULN_TAG="${VULN_TAG:-vuln-sbom}"
API_HOST="${API_HOST:-bootcamp-api.${NS}.svc.cluster.local}"
API_PORT="${API_PORT:-3000}"
KYVERNO_ECR_SECRET="${KYVERNO_ECR_SECRET:-kyverno-ecr-creds}"
WORKDIR="${WORKDIR:-$(pwd)}"

IMG_SIGNED="${ECR_REGISTRY}/${IMAGE_REPO}:${SIGNED_TAG}"
IMG_UNSIGNED="${ECR_REGISTRY}/${IMAGE_REPO}:${UNSIGNED_TAG}"
IMG_VULN="${ECR_REGISTRY}/${IMAGE_REPO}:${VULN_TAG}"
API_URL="http://${API_HOST}:${API_PORT}"
ARTIFACT_DIR="${WORKDIR}/artifacts/red-team"
TMP_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

banner() { printf '\n=== %s ===\n' "$*"; }
pass() { printf '[PASS] %s\n' "$*"; }
fail() { printf '[FAIL] %s\n' "$*"; exit 1; }

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "Missing required command: $1"
}

need_file_contains() {
  local file="$1"
  local pattern="$2"
  grep -Eq "$pattern" "$file" || fail "Expected pattern not found in ${file}: ${pattern}"
}

record_log() {
  local outfile="$1"
  shift
  "$@" | tee -a "${outfile}"
}

http_code_from_pod() {
  local namespace="$1"
  local pod="$2"
  local url="$3"

  kubectl -n "${namespace}" exec "${pod}" -- \
    curl -s -o /dev/null -w "%{http_code}" --max-time 5 "${url}" || true
}

check_prereqs() {
  banner "Preflight"
  need_cmd kubectl
  need_cmd git
  need_cmd jq
  need_cmd curl
  need_cmd cosign
  need_cmd crane
  need_cmd hubble
  need_cmd aws

  kubectl get namespace "${NS}" >/dev/null 2>&1 || fail "Namespace ${NS} does not exist"
  kubectl -n "${NS}" get deploy bootcamp-api >/dev/null 2>&1 || fail "Deployment ${NS}/bootcamp-api does not exist"
  kubectl -n "${NS}" get deploy bootcamp-frontend >/dev/null 2>&1 || fail "Deployment ${NS}/bootcamp-frontend does not exist"
  kubectl get clusterpolicy prod-zt-verify-images >/dev/null 2>&1 || fail "ClusterPolicy prod-zt-verify-images does not exist"
  kubectl -n "${NS}" get tracingpolicynamespaced block-shell-exec >/dev/null 2>&1 || fail "TracingPolicyNamespaced ${NS}/block-shell-exec does not exist"
  kubectl -n kyverno get secret "${KYVERNO_ECR_SECRET}" >/dev/null 2>&1 || fail "Secret kyverno/${KYVERNO_ECR_SECRET} does not exist"

  mkdir -p "${ARTIFACT_DIR}"
  : > "${ARTIFACT_DIR}/hubble-drops.log"
  : > "${ARTIFACT_DIR}/ztunnel.log"
  : > "${ARTIFACT_DIR}/kyverno.log"
  : > "${ARTIFACT_DIR}/tetragon.log"
  : > "${ARTIFACT_DIR}/falco.log"

  pass "Preflight checks passed"
}

attack_1_cilium() {
  local code

  banner "Attack 1 - cross-namespace HTTP probe"
  kubectl create namespace "${ATTACKER_NS}" --dry-run=client -o yaml | kubectl apply -f -
  kubectl run rogue -n "${ATTACKER_NS}" \
    --image=curlimages/curl:8.8.0 \
    --restart=Never \
    --labels='app=evil' \
    --command -- sleep 120 >/dev/null 2>&1 || true
  kubectl -n "${ATTACKER_NS}" wait --for=condition=Ready pod/rogue --timeout=60s

  code="$(http_code_from_pod "${ATTACKER_NS}" rogue "${API_URL}/api/items")"
  printf 'HTTP code from %s/rogue: %s\n' "${ATTACKER_NS}" "${code}"
  [[ "${code}" =~ ^(000|403)$ ]] || fail "Cross-namespace probe was not blocked (code=${code})"

  record_log "${ARTIFACT_DIR}/hubble-drops.log" \
    hubble observe --namespace "${NS}" --verdict DROPPED --last 10
  pass "Cilium blocked cross-namespace probe (code=${code})"
}

attack_2_istio() {
  local code

  banner "Attack 2 - plaintext or wrong identity connection"
  kubectl create namespace "${PLAIN_NS}" --dry-run=client -o yaml | kubectl apply -f -
  kubectl run plain -n "${PLAIN_NS}" \
    --image=curlimages/curl:8.8.0 \
    --restart=Never \
    --command -- sleep 120 >/dev/null 2>&1 || true
  kubectl -n "${PLAIN_NS}" wait --for=condition=Ready pod/plain --timeout=60s

  code="$(http_code_from_pod "${PLAIN_NS}" plain "${API_URL}/api/items")"
  printf 'HTTP code from %s/plain: %s\n' "${PLAIN_NS}" "${code}"
  [[ "${code}" =~ ^(000|056|403|56)$ ]] || fail "Plaintext or wrong-identity attempt got through (code=${code})"

  record_log "${ARTIFACT_DIR}/ztunnel.log" \
    kubectl -n istio-system logs ds/ztunnel --tail=80
  pass "Istio rejected non-mesh or unauthorized caller (code=${code})"
}

ecr_login() {
  aws ecr get-login-password --region "${AWS_REGION}" | \
    crane auth login -u AWS --password-stdin "${ECR_REGISTRY}" >/dev/null
}

attack_3_kyverno_unsigned() {
  local manifest output

  banner "Attack 3 - deploy unsigned image variant"
  ecr_login
  crane copy alpine:3.20 "${IMG_UNSIGNED}" >/dev/null

  manifest="${TMP_DIR}/rogue-unsigned.yaml"
  cat > "${manifest}" <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: rogue-unsigned
  namespace: ${NS}
spec:
  restartPolicy: Never
  containers:
    - name: c
      image: ${IMG_UNSIGNED}
      command: ["sleep", "60"]
EOF

  set +e
  output="$(kubectl apply -f "${manifest}" 2>&1)"
  set -e
  printf '%s\n' "${output}"
  printf '%s\n' "${output}" | grep -Eqi 'no signatures found|image verification failed|signature-required' \
    || fail "Unsigned image was admitted"

  record_log "${ARTIFACT_DIR}/kyverno.log" \
    kubectl -n kyverno logs deploy/kyverno-admission-controller --tail=80
  pass "Kyverno rejected unsigned image"
}

attack_4_kyverno_sbom() {
  local manifest output predicate

  banner "Attack 4 - deploy image with critical CVE in SBOM"
  ecr_login
  crane copy "${IMG_SIGNED}" "${IMG_VULN}" >/dev/null

  predicate="${TMP_DIR}/vuln-sbom.json"
  cat > "${predicate}" <<'EOF'
{
  "bomFormat": "CycloneDX",
  "specVersion": "1.5",
  "version": 1,
  "components": [
    {
      "type": "library",
      "name": "openssl",
      "version": "1.0.1"
    }
  ],
  "vulnerabilities": [
    {
      "id": "CVE-2014-0160",
      "ratings": [
        {
          "severity": "critical",
          "score": 10.0
        }
      ]
    }
  ]
}
EOF

  cosign attest --yes --predicate "${predicate}" --type cyclonedx "${IMG_VULN}" >/dev/null

  manifest="${TMP_DIR}/rogue-vuln.yaml"
  cat > "${manifest}" <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: rogue-vuln
  namespace: ${NS}
spec:
  restartPolicy: Never
  containers:
    - name: c
      image: ${IMG_VULN}
      command: ["sleep", "60"]
EOF

  set +e
  output="$(kubectl apply -f "${manifest}" 2>&1)"
  set -e
  printf '%s\n' "${output}"
  printf '%s\n' "${output}" | grep -Eqi 'CRITICAL|critical|sbom-attestation-required' \
    || fail "Vulnerable-SBOM image was admitted"

  record_log "${ARTIFACT_DIR}/kyverno.log" \
    kubectl -n kyverno logs deploy/kyverno-admission-controller --tail=120
  pass "Kyverno rejected vulnerable SBOM attestation"
}

attack_5_tetragon() {
  local pod rc

  banner "Attack 5 - kubectl exec /bin/sh"
  pod="$(kubectl -n "${NS}" get pod -l app=bootcamp-api -o jsonpath='{.items[0].metadata.name}')"
  [[ -n "${pod}" ]] || fail "No bootcamp-api pod found in ${NS}"

  set +e
  kubectl -n "${NS}" exec "${pod}" -- /bin/sh -c "echo i_should_never_print"
  rc=$?
  set -e
  printf 'exec returned exit code: %s\n' "${rc}"
  [[ "${rc}" == "137" ]] || fail "Shell ran or returned unexpected code (${rc})"

  record_log "${ARTIFACT_DIR}/tetragon.log" \
    kubectl -n tetragon exec ds/tetragon -c tetragon -- \
      tetra getevents -o compact --pods "${pod}" --namespaces "${NS}"

  {
    kubectl -n falco logs ds/falco --tail=300 || true
  } | grep 'Shell spawned' | tail -3 | tee -a "${ARTIFACT_DIR}/falco.log" >/dev/null || true

  pass "Tetragon SIGKILLed the shell (exit 137)"
}

post_checks() {
  banner "Post-checks"
  need_file_contains "${ARTIFACT_DIR}/hubble-drops.log" 'DROPPED|Policy denied|403'
  need_file_contains "${ARTIFACT_DIR}/ztunnel.log" 'rbac|tls|denied|refused'
  need_file_contains "${ARTIFACT_DIR}/kyverno.log" 'prod-zt-verify-images|signature-required|sbom-attestation-required'
  need_file_contains "${ARTIFACT_DIR}/tetragon.log" 'PROCESS_EXEC|PROCESS_KPROBE|SIGKILL|/bin/sh'
  pass "Evidence files captured under ${ARTIFACT_DIR}"
}

main() {
  check_prereqs
  attack_1_cilium
  attack_2_istio
  attack_3_kyverno_unsigned
  attack_4_kyverno_sbom
  attack_5_tetragon
  post_checks
  banner "All five attacks blocked"
}

main "$@"
