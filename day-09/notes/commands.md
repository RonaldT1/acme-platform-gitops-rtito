# Day 09 - Commands Used

## Infrastructure Management

### Deploy Infrastructure with Terraform

```bash
terraform -chdir=infra init
terraform -chdir=infra plan
terraform -chdir=infra apply
```

### Destroy Infrastructure

```bash
terraform -chdir=infra destroy
```

---

## Docker & ECR

### Build Docker Image

```bash
docker build -f docker/Dockerfile -t bootcamp-api:latest .
```

### Tag Image for ECR

```bash
docker tag bootcamp-api:latest <ECR_REGISTRY>/bootcamp-api:latest
```

### Push to ECR

```bash
docker push <ECR_REGISTRY>/bootcamp-api:latest
```

---

## Kubernetes Deployments

### Deploy Application with Helm

```bash
helm install bootcamp-api ./k8s/charts/bootcamp-api/ -f k8s/charts/bootcamp-api/values.yaml
```

### Update Helm Chart

```bash
helm upgrade bootcamp-api ./k8s/charts/bootcamp-api/ -f k8s/charts/bootcamp-api/values.yaml
```

### Get Helm Status

```bash
helm status bootcamp-api
```

### Delete Helm Release

```bash
helm uninstall bootcamp-api
```

---

## Prometheus

### Port-Forward Prometheus

```bash
kubectl -n monitoring port-forward svc/kps-kube-prometheus-stack-prometheus 9090:9090
```

### Access Prometheus UI

```
http://localhost:9090
```

### Check Prometheus Targets

```
http://localhost:9090/targets
```

---

## Grafana

### Port-Forward Grafana

```bash
kubectl -n monitoring port-forward svc/kps-grafana 3001:80
```

### Access Grafana UI

```
http://localhost:3001
```

### Default Credentials

```
Username: admin
Password: bootcamp-2026
```

---

## Traffic Generation

### Generate Traffic for Testing

```bash
for i in {1..200}; do
  curl -s http://$ALB/api/hello > /dev/null
done
```

Where `$ALB` is the Application Load Balancer endpoint provided by AWS Load Balancer Controller.

---

## Kubernetes Debugging

### Check Pod Status

```bash
kubectl get pods -n default
```

### View Pod Logs

```bash
kubectl logs <POD_NAME>
```

### Describe Pod

```bash
kubectl describe pod <POD_NAME>
```

### List Services

```bash
kubectl get svc
```

### List ServiceMonitors

```bash
kubectl get servicemonitor -n default
```

### Describe ServiceMonitor

```bash
kubectl describe servicemonitor <NAME>
```

---

## PromQL Queries Used

### Runtime Metrics (Working)

```promql
process_resident_memory_bytes
```

### Custom Metrics (Requires Updated Image)

```promql
sum(rate(http_requests_total[1m])) by (status)
```
