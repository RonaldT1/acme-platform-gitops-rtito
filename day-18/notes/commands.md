# Day-18

## Terraform

```bash
cd exercises/aws-bootcamp/infra
terraform fmt
terraform validate
terraform init -reconfigure
terraform plan
terraform apply
terraform output
```

## Kubeconfig

```bash
aws eks update-kubeconfig --region us-east-1 --name bootcamp-rtito-day18-eks
kubectl get nodes
```

## GitHub Actions ECR Login Test

```bash
aws ecr get-login-password --region us-east-1 | \
docker login --username AWS --password-stdin 711387135481.dkr.ecr.us-east-1.amazonaws.com
```

## Local Signature Verification

```bash
export IMAGE=711387135481.dkr.ecr.us-east-1.amazonaws.com/bootcamp-api:56e4631b3535d090fc2dfd6d8a3d8888bd281d14

cosign verify \
  --certificate-identity-regexp "^https://github.com/amartinez-aquaware/bootcamp-2026-4/" \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  ${IMAGE}
```

```bash
cosign verify-attestation \
  --type cyclonedx \
  --certificate-identity-regexp "^https://github.com/amartinez-aquaware/bootcamp-2026-4/" \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  ${IMAGE}
```

```bash
cosign verify-attestation \
  --type vuln \
  --certificate-identity-regexp "^https://github.com/amartinez-aquaware/bootcamp-2026-4/" \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  ${IMAGE}
```

```bash
crane digest ${IMAGE}
rekor-cli search --sha ${DIGEST#sha256:}
```

## Kyverno Install

```bash
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update

helm upgrade --install kyverno kyverno/kyverno \
  -n kyverno \
  --create-namespace
```

## Kyverno ECR Credentials

```bash
aws ecr get-login-password --region us-east-1 | \
kubectl create secret docker-registry kyverno-ecr-creds \
  -n kyverno \
  --docker-server=711387135481.dkr.ecr.us-east-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password-stdin
```

## Kyverno Policy

```bash
kubectl apply -f exercises/aws-bootcamp/k8s/kyverno/cpol-verify-bootcamp-api.yaml
kubectl get clusterpolicy
```

## Signed Image Test

```bash
kubectl apply -f exercises/aws-bootcamp/k8s/kyverno/test-signed-image.yaml
kubectl get pod signed-image-test
```

## Unsigned Image Build And Push

```bash
export AWS_REGION=us-east-1
export ECR_URL=711387135481.dkr.ecr.us-east-1.amazonaws.com/bootcamp-api
export UNSIGNED_TAG=unsigned-test
```

```bash
aws ecr get-login-password --region ${AWS_REGION} | \
docker login --username AWS --password-stdin 711387135481.dkr.ecr.us-east-1.amazonaws.com
```

```bash
cd exercises/aws-bootcamp
docker build -f docker/Dockerfile -t ${ECR_URL}:${UNSIGNED_TAG} .
docker push ${ECR_URL}:${UNSIGNED_TAG}
```

```bash
cd infra
kubectl apply -f ../k8s/kyverno/test-unsigned-image.yaml
```

## Final Verification

```bash
kubectl get cpol verify-bootcamp-api-signatures -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}{"\n"}'
kubectl get pod signed-image-test
kubectl apply -f ../k8s/kyverno/test-unsigned-image.yaml
```

```bash
cosign download attestation ${IMAGE} | jq -r '.payload' | base64 -d | jq '.predicate.components | length'
```

## Cleanup

```bash
kubectl delete pod signed-image-test

cd exercises/aws-bootcamp/infra
terraform destroy
```
