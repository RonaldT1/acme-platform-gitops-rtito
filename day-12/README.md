# Argo Rollouts Canary Deployment Lab

## Overview

This lab demonstrates how to implement progressive delivery on Kubernetes using Argo Rollouts, AWS ALB traffic shaping, Prometheus metrics, and Helm.

The objective is to replace a traditional Kubernetes Deployment with an Argo Rollout capable of:

* Performing canary deployments
* Shifting traffic gradually between stable and canary versions
* Monitoring application health with Prometheus
* Automatically promoting or rolling back releases

---

# Architecture

```text
Client
  ↓
AWS ALB Ingress
  ↓
Stable Service  ←→  Canary Service
  ↓                    ↓
Argo Rollouts controls traffic percentages
  ↓
Pods running different image versions
  ↓
Prometheus scrapes metrics
  ↓
AnalysisTemplate validates rollout health
```

---

# Technologies Used

* Kubernetes (EKS)
* Helm
* Argo Rollouts
* AWS Load Balancer Controller
* Prometheus Operator
* ServiceMonitor
* Docker / Amazon ECR

---

# Project Structure

```text
k8s/
└── charts/
    └── bootcamp-api/
        ├── Chart.yaml
        ├── values.yaml
        └── templates/
            ├── rollout.yaml
            ├── ingress.yaml
            ├── service-stable.yaml
            ├── service-canary.yaml
            ├── servicemonitor-stable.yaml
            ├── servicemonitor-canary.yaml
            └── analysistemplate.yaml
```

---

# Stable Service

This service routes traffic to the stable version of the application.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: bootcamp-api
  namespace: bootcamp
spec:
  type: ClusterIP
  ports:
    - port: 80
      targetPort: http
      name: http
  selector:
    app.kubernetes.io/name: bootcamp-api
```

---

# Canary Service

This service is used by Argo Rollouts to send traffic to the canary version.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: bootcamp-api-canary
  namespace: bootcamp
spec:
  type: ClusterIP
  ports:
    - port: 80
      targetPort: http
      name: http
  selector:
    app.kubernetes.io/name: bootcamp-api
```

---

# ServiceMonitors

Prometheus needs separate metrics for stable and canary traffic.

The stable ServiceMonitor already exists.
A second ServiceMonitor is created for the canary service.

## Canary ServiceMonitor

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: bootcamp-api-canary
  namespace: monitoring
spec:
  namespaceSelector:
    matchNames:
      - bootcamp
  selector:
    matchLabels:
      app: bootcamp-api-canary
  endpoints:
    - port: http
      path: /metrics
      interval: 15s
```

This allows Prometheus to generate metrics with:

```text
service="bootcamp-api-canary"
```

These metrics are later consumed by Argo Rollouts AnalysisTemplates.

---

# Argo Rollout

The Deployment is replaced with a Rollout resource.

## Example Rollout

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: bootcamp-api
  namespace: bootcamp
spec:
  replicas: 3

  selector:
    matchLabels:
      app.kubernetes.io/name: bootcamp-api

  template:
    metadata:
      labels:
        app.kubernetes.io/name: bootcamp-api
    spec:
      containers:
        - name: api
          image: <ECR_IMAGE>:v2
          ports:
            - containerPort: 8080
              name: http

  strategy:
    canary:
      stableService: bootcamp-api
      canaryService: bootcamp-api-canary

      trafficRouting:
        alb:
          ingress: bootcamp-api
          servicePort: 80

      steps:
        - setWeight: 20
        - pause:
            duration: 30s

        - analysis:
            templates:
              - templateName: success-rate-check

        - setWeight: 50
        - pause:
            duration: 30s

        - setWeight: 100
```

---

# AnalysisTemplate

The AnalysisTemplate validates rollout health using Prometheus metrics.

## Example

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AnalysisTemplate
metadata:
  name: success-rate-check
  namespace: bootcamp
spec:
  metrics:
    - name: success-rate
      interval: 30s
      successCondition: result[0] >= 0.95
      provider:
        prometheus:
          address: http://prometheus-operated.monitoring.svc.cluster.local:9090
          query: |
            sum(rate(http_requests_total{
              service="bootcamp-api-canary",
              status!~"5.."
            }[1m]))
            /
            sum(rate(http_requests_total{
              service="bootcamp-api-canary"
            }[1m]))
```

If the success rate falls below 95%, the rollout fails automatically.

---

# Deploy the Lab

## 1. Install Argo Rollouts

```bash
kubectl create namespace argo-rollouts

kubectl apply -n argo-rollouts \
  -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
```

---

## 2. Install kubectl plugin

```bash
brew install argoproj/tap/kubectl-argo-rollouts
```

Linux:

```bash
curl -LO https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-linux-amd64
chmod +x kubectl-argo-rollouts-linux-amd64
sudo mv kubectl-argo-rollouts-linux-amd64 /usr/local/bin/kubectl-argo-rollouts
```

---

## 3. Deploy Helm Chart

```bash
helm upgrade --install bootcamp-api ./k8s/charts/bootcamp-api \
  --namespace bootcamp \
  --create-namespace
```

---

# Verify Rollout

## Check rollout status

```bash
kubectl argo rollouts get rollout bootcamp-api -n bootcamp
```

---

## Watch rollout live

```bash
kubectl argo rollouts get rollout bootcamp-api -n bootcamp --watch
```

---

## Promote manually

```bash
kubectl argo rollouts promote bootcamp-api -n bootcamp
```

---

## Abort rollout

```bash
kubectl argo rollouts abort bootcamp-api -n bootcamp
```

---

# Trigger a New Release

Update the image tag:

```yaml
image: <ECR_IMAGE>:v3
```

Then upgrade the Helm release:

```bash
helm upgrade --install bootcamp-api ./k8s/charts/bootcamp-api \
  --namespace bootcamp
```

Argo Rollouts will:

1. Create canary pods
2. Shift traffic gradually
3. Run analysis checks
4. Promote automatically if healthy
5. Roll back if metrics fail

---

# Observability

Useful commands:

## Rollout history

```bash
kubectl argo rollouts history bootcamp-api -n bootcamp
```

## List AnalysisRuns

```bash
kubectl get analysisruns -n bootcamp
```

## Describe rollout

```bash
kubectl describe rollout bootcamp-api -n bootcamp
```

---

# Key Learning Points

* Difference between Deployment and Rollout
* Progressive delivery concepts
* Canary deployments
* Traffic shaping with AWS ALB
* Prometheus-based automated validation
* Automatic rollback strategies
* Helm integration with Argo Rollouts

---

# Cleanup

```bash
helm uninstall bootcamp-api -n bootcamp

kubectl delete namespace argo-rollouts
kubectl delete namespace bootcamp
```

---

# Final Notes

This lab demonstrates a production-style deployment strategy commonly used by platform engineering and DevOps teams.

Instead of deploying new versions directly to 100% of users, traffic is shifted gradually while metrics are analyzed automatically.

This approach reduces deployment risk and improves application reliability.

And yes… once you start using progressive delivery, regular Deployments begin to feel emotionally outdated 😄
