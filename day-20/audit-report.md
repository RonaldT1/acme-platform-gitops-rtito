# Zero Trust Capstone - Audit Report

Run date: 2026-06-08
Cluster: bootcamp-rtito-day20-eks
Namespace: prod-zt
Image: 711387135481.dkr.ecr.us-east-1.amazonaws.com/bootcamp-api:b9ed51cc48866e5421f272cb759b89eca8c0295d

## Layer-by-layer results

### Layer 1 - Cilium L7 NetworkPolicy
- Attack: cross-namespace HTTP probe from `attacker-ns/rogue`
- Result: PASS
- Runtime result: HTTP code `000`
- Evidence: `artifacts/red-team/hubble-drops.log`
- Note: Hubble recorded `Policy denied DROPPED` entries against `prod-zt/bootcamp-api`

### Layer 2 - Istio Ambient STRICT mTLS + AuthorizationPolicy
- Attack: plaintext or wrong-identity call from `plain-attacker/plain`
- Result: PASS
- Runtime result: HTTP code `000`
- Evidence: `artifacts/red-team/ztunnel.log`
- Note: ztunnel logs captured access and timeout evidence consistent with blocked/non-routable non-mesh traffic

### Layer 3 - Kyverno verifyImages (keyless signature)
- Attack: deploy `bootcamp-api:unsigned`
- Result: PASS
- Evidence: `artifacts/red-team/kyverno.log`
- Note: Kyverno denied the pod because no matching signature was found

### Layer 4 - SBOM attestation gate
- Attack: skipped in compatibility mode
- Result: WARN
- Evidence: `audit-evidence.txt`
- Note: current policy verifies presence of a valid CycloneDX SBOM attestation, but does not yet enforce `0` CRITICAL vulnerabilities from the Trivy attestation path

### Layer 5 - Tetragon namespaced shell blocking
- Attack: `kubectl exec /bin/sh` into `bootcamp-api`
- Result: PASS with warning
- Runtime result: exit code `137`
- Evidence: `audit-evidence.txt`
- Note: functional enforcement was proven by `137`; `artifacts/red-team/tetragon.log` did not capture the expected event pattern during the run

## Summary

| # | Layer | Verdict |
|---|---|---|
| 1 | Cilium L7 | PASS |
| 2 | Istio Ambient mTLS/AuthZ | PASS |
| 3 | Kyverno signature verification | PASS |
| 4 | SBOM vulnerability gate | WARN |
| 5 | Tetragon shell blocking | PASS |

## Overall assessment

The capstone ran successfully enough to demonstrate that Layers 1, 2, 3, and 5 are operational in this cluster. Layer 4 remains partially implemented because the current pipeline and policy do not yet enforce the vulnerable-attestation rejection path described in the original lab.
