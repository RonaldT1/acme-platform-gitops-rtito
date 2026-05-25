# Day 10 — Evidence & Validation

## Evidence Collected

* EKS cluster provisioned with Terraform
* AWS Load Balancer Controller installed and handling traffic
* ArgoCD installed and synchronizing the GitOps application
* bootcamp-api deployed via Helm through ArgoCD
* HPA reacting to load and scaling replicas
* Cluster Autoscaler adding nodes under load
* Broken deployment introduced via invalid image tag
* ArgoCD detected the broken deployment and showed failing pods
* Git revert restored the previous healthy configuration
* ArgoCD reconciled automatically and recovered the application
* Application pods returned to `Running`
* Rollout history available for `bootcamp-api`
* Verified HPA metrics and scaling behavior

## Validation Steps

### HPA Observability

```bash
kubectl -n bootcamp get hpa -w
kubectl get nodes -w
```

### GitOps Failure Simulation

```bash
git add .
git commit -m "day-10: simulate broken gitops deployment"
git push
```

### Rollback Validation

```bash
git revert HEAD
git push
```

### Kubernetes Health

```bash
kubectl -n bootcamp get pods
kubectl -n bootcamp rollout history deploy/bootcamp-api
kubectl -n bootcamp get hpa bootcamp-api
```

## Cleanup Evidence

* Terraform destroy attempted and failed initially due to existing AWS Load Balancers and Security Groups
* Manual cleanup of ALBs and orphaned Security Groups completed
* Terraform state lock recovery performed as needed
* Infrastructure was eventually destroyed successfully

---

# Day 10 — Evidence & Validation

## Evidence Collected

* EKS cluster provisioned with Terraform
* AWS Load Balancer Controller installed and handling traffic
* ArgoCD installed and synchronizing the GitOps application
* bootcamp-api deployed via Helm through ArgoCD
* HPA reacting to load and scaling replicas
* Cluster Autoscaler adding nodes under load
* Broken deployment introduced via invalid image tag
* ArgoCD detected the broken deployment and showed failing pods
* Git revert restored the previous healthy configuration
* ArgoCD reconciled automatically and recovered the application
* Application pods returned to `Running`
* Rollout history available for `bootcamp-api`
* Verified HPA metrics and scaling behavior

## Validation Steps

### HPA Observability

```bash
kubectl -n bootcamp get hpa -w
kubectl get nodes -w
```

### GitOps Failure Simulation

```bash
git add .
git commit -m "day-10: simulate broken gitops deployment"
git push
```

### Rollback Validation

```bash
git revert HEAD
git push
```

### Kubernetes Health

```bash
kubectl -n bootcamp get pods
kubectl -n bootcamp rollout history deploy/bootcamp-api
kubectl -n bootcamp get hpa bootcamp-api
```

## Cleanup Evidence

* Terraform destroy attempted and failed initially due to existing AWS Load Balancers and Security Groups
* Manual cleanup of ALBs and orphaned Security Groups completed
* Terraform state lock recovery performed as needed
* Infrastructure was eventually destroyed successfully
