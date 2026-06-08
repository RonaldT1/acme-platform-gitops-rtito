# Day-19

## Cluster Access

```bash
aws eks update-kubeconfig --region us-east-1 --name bootcamp-rtito-day19-eks
```

## Kernel Pre-Check

```bash
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.nodeInfo.osImage}{"\t"}{.status.nodeInfo.kernelVersion}{"\n"}{end}'
```

## Falco Install

```bash
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update

kubectl create namespace falco 2>/dev/null || true

helm upgrade --install falco falcosecurity/falco \
  --version 9.0.0 \
  --namespace falco \
  -f exercises/aws-bootcamp/infra/falco-values.yaml

kubectl -n falco rollout status ds/falco --timeout=180s
```

## Observability Prerequisite

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

kubectl create namespace observability 2>/dev/null || true

helm upgrade --install kps prometheus-community/kube-prometheus-stack \
  --namespace observability \
  --version 58.0.0 \
  --set grafana.adminPassword='bootcamp-2026' \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false
```

```bash
kubectl -n observability get pods
kubectl -n observability get svc | grep alertmanager
```

## Falco Custom Rules

```bash
kubectl apply -f exercises/aws-bootcamp/k8s/falco/rules/bootcamp-shell-in-container.yaml
```

```bash
helm upgrade falco falcosecurity/falco \
  --version 9.0.0 \
  --namespace falco \
  --reuse-values \
  -f exercises/aws-bootcamp/infra/falco-values-extra.yaml

kubectl -n falco rollout restart ds/falco
kubectl -n falco rollout status ds/falco --timeout=180s
```

## Alertmanager Route

```bash
kubectl apply -f exercises/aws-bootcamp/k8s/observability/alertmanager-route-falco.yaml
kubectl -n observability get alertmanagerconfig falco-runtime
```

## Tetragon Install

```bash
helm repo add cilium https://helm.cilium.io/
helm repo update

kubectl create namespace tetragon 2>/dev/null || true

helm upgrade --install tetragon cilium/tetragon \
  --version 1.7.0 \
  --namespace tetragon \
  -f exercises/aws-bootcamp/infra/tetragon-values.yaml

kubectl -n tetragon rollout status ds/tetragon --timeout=180s
```

## Build And Push App Images

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 711387135481.dkr.ecr.us-east-1.amazonaws.com
```

```bash
cd exercises/aws-bootcamp
docker build -f docker/Dockerfile -t 711387135481.dkr.ecr.us-east-1.amazonaws.com/bootcamp-api:v1 .
docker tag 711387135481.dkr.ecr.us-east-1.amazonaws.com/bootcamp-api:v1 711387135481.dkr.ecr.us-east-1.amazonaws.com/bootcamp-api:v2
docker push 711387135481.dkr.ecr.us-east-1.amazonaws.com/bootcamp-api:v1
docker push 711387135481.dkr.ecr.us-east-1.amazonaws.com/bootcamp-api:v2
cd ../..
```

## Deploy bootcamp-prod

```bash
kubectl create namespace bootcamp-prod
kubectl apply -f exercises/aws-bootcamp/k8s/bootcamp-prod/api-v1-v2.yaml
kubectl -n bootcamp-prod get pods
```

## Tetragon Policy

```bash
kubectl apply -f exercises/aws-bootcamp/k8s/tetragon/tp-block-shell.yaml
kubectl -n bootcamp-prod get tracingpolicynamespaced block-shell-exec
```

## Runtime Verification

```bash
POD=$(kubectl -n bootcamp-prod get pod -l app=bootcamp-api,version=v1 -o jsonpath='{.items[0].metadata.name}')
echo $POD
```

```bash
kubectl -n bootcamp-prod exec -it ${POD} -- /bin/sh
```

## Falco Detection Diagnostic

```bash
kubectl delete tracingpolicynamespaced -n bootcamp-prod block-shell-exec
kubectl -n bootcamp-prod exec -it ${POD} -- /bin/sh
```

```bash
kubectl -n bootcamp-prod get pod ${POD} -o wide
kubectl -n falco get pods -o wide
```

```bash
kubectl -n falco logs <falco-pod-on-same-node> -c falco --tail=300 | grep -Ei 'Terminal shell in container|Shell spawned in bootcamp-prod container|bootcamp-prod|busybox'
```

## Re-Enable Tetragon Enforcement

```bash
kubectl apply -f exercises/aws-bootcamp/k8s/tetragon/tp-block-shell.yaml
kubectl -n bootcamp-prod exec -it ${POD} -- /bin/sh
```

## Verification Commands

```bash
kubectl -n falco get ds falco
kubectl -n falco logs ds/falco --tail=200 | grep -iE "modern|driver|BPF"
kubectl -n tetragon get ds tetragon
kubectl -n bootcamp-prod get tracingpolicynamespaced
kubectl run shell-test -n default --rm -it --image=busybox -- sh
```

## Notes On Non-Ideal Checks

```bash
kubectl -n falco logs deploy/falco-falcosidekick --tail=30 | grep -i alertmanager
```

```bash
kubectl -n observability exec alertmanager-kps-kube-prometheus-stack-alertmanager-0 -c alertmanager -- \
  amtool --alertmanager.url=http://localhost:9093 alert query \
  'alertname="Terminal shell in container"'
```

## Cleanup

```bash
kubectl delete tracingpolicynamespaced -n bootcamp-prod block-shell-exec
helm uninstall tetragon -n tetragon
helm uninstall falco -n falco
```
