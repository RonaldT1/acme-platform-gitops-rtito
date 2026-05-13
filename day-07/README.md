# Day 07 — Helm Deployment on EKS

## Goal

Deploy the `bootcamp-api` application into an EKS cluster using Helm.

---

## What Was Done

- Created and configured the EKS cluster with Terraform.
- Connected `kubectl` to the EKS cluster.
- Validated worker nodes.
- Created a custom Helm chart for `bootcamp-api`.
- Configured the Helm chart with:
  - Deployment
  - Service
  - ConfigMap
  - Secret
  - `values.yaml`
- Deployed the application using Helm.
- Verified pod status.
- Verified the application health endpoint.

---

## Commands Used

### 1. Configure kubeconfig

```bash
aws eks update-kubeconfig \
  --name bootcamp-eks \
  --region us-east-1
```

### 2. Validate nodes

```bash
kubectl get nodes
```

### 3. Create namespace

```bash
kubectl create namespace bootcamp --dry-run=client -o yaml | kubectl apply -f -
```

### 4. Deploy with Helm

```bash
helm upgrade --install bootcamp-api ./k8s/charts/bootcamp-api \
  --namespace bootcamp \
  --set image.repository=$(terraform -chdir=infra output -raw ecr_url)
```

### 5. Verify deployment

```bash
kubectl -n bootcamp get pods
```

```bash
kubectl -n bootcamp rollout status deploy/bootcamp-api
```

### 6. Port-forward the service

```bash
kubectl -n bootcamp port-forward svc/bootcamp-api 8080:80
```

### 7. Health check

```bash
curl http://localhost:8080/health
```

---

## Issues Encountered

- Existing IAM roles and EKS resources caused conflicts.
- Terraform state lock in DynamoDB.
- `ErrImagePull` because ECR had no image pushed yet.
- Missing `httpRoute.enabled` value in the Helm chart.

---

## Fixes Applied

- Reused or cleaned existing AWS resources.
- Released the Terraform lock using:

```bash
terraform force-unlock <LOCK_ID>
```

- Pushed the Docker image to ECR.
- Added the missing Helm values configuration.

---

## Result

The application was deployed successfully into EKS using Helm.

Pods reached the `Running` state and the `/health` endpoint responded correctly.