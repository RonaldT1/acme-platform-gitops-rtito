# Day 10 — Commands Used

## Load Generation

```bash
kubectl run -it --rm load --image=busybox --restart=Never -- \
  sh -c "while true; do wget -q -O- http://$ALB/api/hello; done"
```

## HPA and Node Monitoring

```bash
kubectl -n bootcamp get hpa -w
kubectl get nodes -w
```

## GitOps Deployment Simulation

```bash
git add .
git commit -m "day-10: simulate broken gitops deployment"
git push
```

## Rollback and Reconciliation

```bash
git revert HEAD
git push
```

## Kubernetes Verification

```bash
kubectl -n bootcamp get pods
kubectl -n bootcamp rollout history deploy/bootcamp-api
kubectl -n bootcamp get hpa bootcamp-api
```

## Cleanup

```bash
terraform destroy
```

## Additional ArgoCD Checks

```bash
kubectl -n bootcamp get applications
kubectl -n bootcamp get app bootcamp-api
```

---

# Day 10 — Commands Used

## Load Generation

```bash
kubectl run -it --rm load --image=busybox --restart=Never -- \
  sh -c "while true; do wget -q -O- http://$ALB/api/hello; done"
```

## HPA and Node Monitoring

```bash
kubectl -n bootcamp get hpa -w
kubectl get nodes -w
```

## GitOps Deployment Simulation

```bash
git add .
git commit -m "day-10: simulate broken gitops deployment"
git push
```

## Rollback and Reconciliation

```bash
git revert HEAD
git push
```

## Kubernetes Verification

```bash
kubectl -n bootcamp get pods
kubectl -n bootcamp rollout history deploy/bootcamp-api
kubectl -n bootcamp get hpa bootcamp-api
```

## Cleanup

```bash
terraform destroy
```

## Additional ArgoCD Checks

```bash
kubectl -n bootcamp get applications
kubectl -n bootcamp get app bootcamp-api
```
