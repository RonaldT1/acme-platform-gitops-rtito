# Day 15 — Commands

## Terraform

```bash
terraform init
terraform plan
terraform apply
aws eks update-kubeconfig --region us-east-1 --name bootcamp-rtito-day15-eks
```

## Base Platform

```bash
helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=bootcamp-rtito-day15-eks \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=us-east-1 \
  --set vpcId=vpc-0e1011525be97d3e8
```

```bash
helm upgrade --install karpenter-crd oci://public.ecr.aws/karpenter/karpenter-crd \
  --version 1.0.11 \
  --namespace karpenter \
  --create-namespace

helm upgrade --install karpenter oci://public.ecr.aws/karpenter/karpenter \
  --version 1.0.11 \
  --namespace karpenter \
  --create-namespace \
  -f exercises/aws-bootcamp/infra/karpenter-values.yaml
```

```bash
helm upgrade --install argo-rollouts argo/argo-rollouts \
  --namespace argo-rollouts \
  -f exercises/aws-bootcamp/infra/argo-rollouts-values.yaml
```

```bash
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set prometheus.prometheusSpec.enableRemoteWriteReceiver=true
```

## Observability

```bash
helm upgrade --install opentelemetry-operator open-telemetry/opentelemetry-operator \
  --namespace observability \
  -f exercises/aws-bootcamp/infra/otel-operator-values.yaml

helm upgrade --install tempo grafana/tempo \
  --namespace observability \
  -f exercises/aws-bootcamp/infra/tempo-values.yaml

helm upgrade --install loki grafana/loki \
  --namespace observability \
  -f exercises/aws-bootcamp/infra/loki-values.yaml
```

```bash
kubectl apply -f exercises/aws-bootcamp/k8s/otel/
```

## Application

```bash
docker build -f docker/Dockerfile \
  -t 711387135481.dkr.ecr.us-east-1.amazonaws.com/bootcamp-rtito-day15-api:day15-base .

docker push 711387135481.dkr.ecr.us-east-1.amazonaws.com/bootcamp-rtito-day15-api:day15-base
```

```bash
helm upgrade --install bootcamp-api exercises/aws-bootcamp/k8s/charts/bootcamp-api \
  --namespace bootcamp
```

## ArgoCD

```bash
kubectl apply -f ~/ronald-bootcamp-gitops/bootcamp-api/argocd-app.yaml
kubectl get applications.argoproj.io -A
```

## Kyverno

```bash
helm upgrade --install kyverno kyverno/kyverno \
  --namespace kyverno \
  --create-namespace \
  -f exercises/aws-bootcamp/infra/kyverno-values.yaml

helm upgrade --install policy-reporter policy-reporter/policy-reporter \
  --namespace kyverno \
  --set ui.enabled=true \
  --set kyvernoPlugin.enabled=true
```

```bash
kubectl apply -f exercises/aws-bootcamp/k8s/kyverno/
```

## Backstage

```bash
kubectl apply -f exercises/aws-bootcamp/k8s/backstage/rbac.yaml
```

```bash
helm upgrade --install backstage backstage/backstage \
  --namespace backstage \
  -f exercises/aws-bootcamp/infra/backstage-values.yaml
```

```bash
kubectl -n backstage port-forward svc/backstage 7007:7007
```
