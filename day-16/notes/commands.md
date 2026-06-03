# Day 16 — Commands

## Terraform And Kubeconfig

Run these only after recreating the infrastructure for the lab:

```bash
cd exercises/aws-bootcamp/infra
terraform fmt
terraform validate
terraform init
terraform plan
terraform apply
aws eks update-kubeconfig --region us-east-1 --name bootcamp-rtito-day16-eks
```

## Base Controllers

```bash
kubectl apply -f exercises/aws-bootcamp/k8s/platform/aws-load-balancer-controller-serviceaccount.yaml
```

```bash
helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=bootcamp-rtito-day16-eks \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=us-east-1 \
  --set vpcId=vpc-0d0bbcaf386ebb9b0
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

## Base Checks

```bash
kubectl -n kube-system get ds aws-node -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
kubectl get nodes -o wide
kubectl -n kube-system get ds aws-node -o yaml > /tmp/aws-node-backup.yaml
```

## Application

Build and push the app image after recreating ECR and the cluster:

```bash
docker build -f exercises/aws-bootcamp/docker/Dockerfile \
  -t 711387135481.dkr.ecr.us-east-1.amazonaws.com/bootcamp-rtito-day16-api:day16-base \
  exercises/aws-bootcamp

docker push 711387135481.dkr.ecr.us-east-1.amazonaws.com/bootcamp-rtito-day16-api:day16-base
```

```bash
kubectl apply -f exercises/aws-bootcamp/k8s/apps/bootcamp-excess-media-namespace.yaml
kubectl apply -f exercises/aws-bootcamp/k8s/apps/bootcamp-api.yaml
kubectl apply -f exercises/aws-bootcamp/k8s/apps/bootcamp-frontend.yaml
kubectl -n bootcamp-excess-media rollout status deploy/bootcamp-api --timeout=180s
kubectl -n bootcamp-excess-media rollout status deploy/bootcamp-frontend --timeout=180s
```

## Cilium Install

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

```bash
kubectl -n kube-system rollout status ds/cilium --timeout=300s
kubectl -n kube-system rollout status deploy/cilium-operator --timeout=180s
kubectl -n kube-system rollout status deploy/hubble-relay --timeout=180s
kubectl -n kube-system rollout status deploy/hubble-ui --timeout=180s
```

Restart workloads after Cilium install so chained mode applies to recreated pods:

```bash
kubectl rollout restart deploy/bootcamp-api -n bootcamp-excess-media
kubectl rollout restart deploy/bootcamp-frontend -n bootcamp-excess-media
kubectl -n bootcamp-excess-media rollout status deploy/bootcamp-api --timeout=180s
kubectl -n bootcamp-excess-media rollout status deploy/bootcamp-frontend --timeout=180s
```

## Hubble

```bash
kubectl apply -f exercises/aws-bootcamp/k8s/hubble/hubble-ingress.yaml
```

```bash
kubectl -n kube-system port-forward svc/hubble-relay 4245:80 &
hubble observe --namespace bootcamp-excess-media --protocol http --last 20
```

## L7 Policy

```bash
kubectl apply -f exercises/aws-bootcamp/k8s/cilium/cnp-api-l7.yaml
kubectl -n bootcamp-excess-media get cnp api-l7
```

## Verification

```bash
API_SVC=bootcamp-api.bootcamp-excess-media.svc.cluster.local:3000

kubectl exec -n bootcamp-excess-media deploy/bootcamp-frontend -- \
  curl -s -o /dev/null -w "%{http_code}\n" http://${API_SVC}/api/items

kubectl exec -n bootcamp-excess-media deploy/bootcamp-frontend -- \
  curl -s -o /dev/null -w "%{http_code}\n" \
  -H 'Content-Type: application/json' \
  -X POST http://${API_SVC}/api/login \
  -d '{"user":"x"}'

kubectl exec -n bootcamp-excess-media deploy/bootcamp-frontend -- \
  curl -s -o /dev/null -w "%{http_code}\n" -X DELETE http://${API_SVC}/api/items/1
```
