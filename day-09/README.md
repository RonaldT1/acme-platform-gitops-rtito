# Day 09 - Observability Stack on EKS

## Objective

Implement a basic observability stack on Kubernetes using:

* Prometheus
* Grafana
* ServiceMonitor
* Custom metrics with `prom-client`
* Amazon EKS
* Helm

The laboratory aimed to deploy an instrumented Node.js application with Prometheus metrics and validate metric scraping and visualization within Kubernetes.

---

## Architecture

```
Node.js Application
        ↓
/metrics Endpoint
        ↓
Kubernetes Service
        ↓
ServiceMonitor
        ↓
Prometheus Scraping
        ↓
Grafana Dashboard
```

---

## Technologies Used

* AWS EKS
* Terraform
* Kubernetes
* Helm
* Prometheus
* Grafana
* Node.js
* Docker
* Amazon ECR
* AWS Load Balancer Controller

---

## Infrastructure Deployment

Infrastructure was deployed using Terraform.

### Components Created

* VPC
* Public and private subnets
* EKS Cluster
* Managed Node Group
* IAM Roles
* Amazon ECR
* AWS Load Balancer Controller

---

## Metrics Instrumentation

The application was instrumented using the `prom-client` library.

### Implemented Metrics

* Default Node.js metrics
* Custom metric: `http_requests_total`

**Metrics Endpoint:** `/metrics`

---

## Prometheus

Prometheus was deployed using the chart: `kube-prometheus-stack`

### Validations Performed

✅ ServiceMonitor detected correctly
✅ Targets in `UP` state
✅ Scraping functional
✅ PromQL queries working

---

## Grafana

Grafana was successfully connected to Prometheus.

### Validations Performed

✅ Prometheus datasource functional
✅ Dashboards operational
✅ Real-time metrics visualization
✅ Time Series working

---

## Lessons Learned

* How to instrument Node.js applications with Prometheus
* How metric scraping works in Kubernetes
* ServiceMonitor usage
* Basic PromQL queries
* Prometheus + Grafana integration
* Complete pipeline flow: Code → Docker → ECR → Kubernetes → Prometheus → Grafana
* Importance of rebuilding and redeploying updated container images in Kubernetes
* Difference between local code and the actual deployed container

---

## Final Status

✅ EKS deployed successfully
✅ Prometheus operational
✅ Grafana operational
✅ Scraping operational
✅ Dashboards operational
✅ Metrics visible
✅ Infrastructure destroyed successfully

For detailed commands, see [notes/commands.md](notes/commands.md).
For evidence and validation details, see [deliverables/evidence.md](deliverables/evidence.md).
