# Day-17

## Terraform

```bash
cd exercises/aws-bootcamp/infra
terraform fmt
terraform validate
terraform init -reconfigure
terraform plan
terraform apply
```

## Kubeconfig

```bash
aws eks update-kubeconfig --region us-east-1 --name bootcamp-rtito-day17-eks
kubectl get nodes
```

## Image Build And Push

```bash
aws ecr get-login-password --region us-east-1 | \
docker login --username AWS --password-stdin 711387135481.dkr.ecr.us-east-1.amazonaws.com

docker build -f exercises/aws-bootcamp/docker/Dockerfile \
  -t 711387135481.dkr.ecr.us-east-1.amazonaws.com/bootcamp-rtito-day17-api:v1 \
  exercises/aws-bootcamp

docker push 711387135481.dkr.ecr.us-east-1.amazonaws.com/bootcamp-rtito-day17-api:v1

docker tag \
  711387135481.dkr.ecr.us-east-1.amazonaws.com/bootcamp-rtito-day17-api:v1 \
  711387135481.dkr.ecr.us-east-1.amazonaws.com/bootcamp-rtito-day17-api:v2

docker push 711387135481.dkr.ecr.us-east-1.amazonaws.com/bootcamp-rtito-day17-api:v2
```

## Day 16 Baseline Restore

```bash
kubectl apply -f exercises/aws-bootcamp/k8s/platform/aws-load-balancer-controller-serviceaccount.yaml

helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=bootcamp-rtito-day17-eks \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=us-east-1 \
  --set vpcId=vpc-09610d208874ad053
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

kubectl apply -f exercises/aws-bootcamp/k8s/karpenter/
```

```bash
helm repo add cilium https://helm.cilium.io/
helm repo update

API_SERVER_IP=$(kubectl get endpoints kubernetes -o jsonpath='{.subsets[0].addresses[0].ip}')
API_SERVER_PORT=$(kubectl get endpoints kubernetes -o jsonpath='{.subsets[0].ports[0].port}')

helm upgrade --install cilium cilium/cilium \
  --version 1.19.4 \
  --namespace kube-system \
  --set k8sServiceHost=${API_SERVER_IP} \
  --set k8sServicePort=${API_SERVER_PORT} \
  -f exercises/aws-bootcamp/infra/cilium-values.yaml
```

## Istio Ambient

```bash
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update

ISTIO_VERSION=1.30.0
NS=istio-system
kubectl create namespace $NS 2>/dev/null || true
kubectl label namespace $NS istio-injection=disabled --overwrite
```

```bash
kubectl apply --server-side \
  -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.5.1/standard-install.yaml
```

```bash
helm upgrade --install istio-base istio/base \
  --version ${ISTIO_VERSION} \
  --namespace $NS \
  --set defaultRevision=default

helm upgrade --install istiod istio/istiod \
  --version ${ISTIO_VERSION} \
  --namespace $NS \
  -f exercises/aws-bootcamp/infra/istiod-values.yaml

helm upgrade --install istio-cni istio/cni \
  --version ${ISTIO_VERSION} \
  --namespace $NS \
  -f exercises/aws-bootcamp/infra/istio-cni-values.yaml

helm upgrade --install ztunnel istio/ztunnel \
  --version ${ISTIO_VERSION} \
  --namespace $NS \
  -f exercises/aws-bootcamp/infra/ztunnel-values.yaml
```

## Ambient Namespace And Waypoint

```bash
kubectl create namespace bootcamp-prod 2>/dev/null || true
kubectl label namespace bootcamp-prod istio.io/dataplane-mode=ambient --overwrite
```

```bash
kubectl apply -f - <<'EOF'
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: bootcamp-prod-waypoint
  namespace: bootcamp-prod
  labels:
    istio.io/waypoint-for: service
spec:
  gatewayClassName: istio-waypoint
  listeners:
    - name: mesh
      port: 15008
      protocol: HBONE
EOF

kubectl label namespace bootcamp-prod \
  istio.io/use-waypoint=bootcamp-prod-waypoint \
  --overwrite
```

## App And Policies

```bash
kubectl apply -f exercises/aws-bootcamp/k8s/bootcamp-prod/api-v1-v2.yaml
kubectl apply -f exercises/aws-bootcamp/k8s/bootcamp-prod/peer-authentication-strict.yaml
kubectl apply -f exercises/aws-bootcamp/k8s/bootcamp-prod/authz-frontend-only.yaml
kubectl apply -f exercises/aws-bootcamp/k8s/bootcamp-prod/traffic-split.yaml
```

## Verification

```bash
kubectl create sa -n bootcamp-prod load-tester
kubectl run load-tester -n bootcamp-prod \
  --overrides='{"spec":{"serviceAccountName":"load-tester"}}' \
  --image=curlimages/curl:8.8.0 --restart=Never -- sleep 3600
```

```bash
kubectl exec -n bootcamp-prod load-tester -- sh -c '
  v1=0; v2=0; slow=0
  for i in $(seq 1 100); do
    start=$(date +%s%N)
    body=$(curl -s http://bootcamp-api.bootcamp-prod.svc.cluster.local:3000/api/version)
    end=$(date +%s%N)
    dur_ms=$(( (end - start) / 1000000 ))
    case "$body" in
      *v1*) v1=$((v1+1));;
      *v2*) v2=$((v2+1));;
    esac
    [ $dur_ms -gt 1900 ] && slow=$((slow+1))
  done
  echo "v1=$v1  v2=$v2  slow_2s=$slow"
'
```

```bash
kubectl create ns no-mesh --dry-run=client -o yaml | kubectl apply -f -
kubectl run curl-nomesh -n no-mesh \
  --image=curlimages/curl:8.8.0 --restart=Never -- sleep 3600

kubectl exec -n no-mesh curl-nomesh -- sh -c '
  curl -s -o /dev/null -w "%{http_code}\n" \
  http://bootcamp-api.bootcamp-prod.svc.cluster.local:3000/api/version
  rc=$?
  echo "exit_code=$rc"
'
```
