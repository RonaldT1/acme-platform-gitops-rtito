# Day 14 — OpenTelemetry on EKS: traces, metrics, logs unified

## Overview

In this lab, I implemented a full OpenTelemetry pipeline on Amazon EKS on top of the existing observability stack.

The final platform includes:

- OpenTelemetry Operator
- a gateway OpenTelemetryCollector for OTLP ingest, Kubernetes enrichment, and tail sampling
- a DaemonSet OpenTelemetryCollector for node-level logs and kubelet metrics
- Grafana Tempo for traces
- Grafana Loki for logs
- Prometheus remote write for metrics
- automatic Node.js instrumentation for `bootcamp-api`

The end result is a working observability path where the application emits traces, metrics, and logs through OpenTelemetry collectors into the Grafana stack.

## Goal

Stand up a unified telemetry pipeline so that:

- traces are sent to Tempo
- logs are sent to Loki
- metrics are sent to Prometheus through remote write
- `bootcamp-api` is auto-instrumented with the OpenTelemetry Operator
- slow requests can be located from Grafana using Tempo and correlated with logs and metrics

## Architecture

```text
bootcamp-api
  |
  | auto-instrumented OTLP
  v
gateway OpenTelemetryCollector
  | \
  |  \---> Loki
  |------> Tempo
  \------> Prometheus (remote write)

node OpenTelemetryCollector (DaemonSet)
  |
  | filelog + kubeletstats
  v
gateway OpenTelemetryCollector
```

## Components deployed

### 1. OpenTelemetry Operator

The OpenTelemetry Operator was installed successfully and used to manage both collector CRs and the Node.js auto-instrumentation injection.

### 2. Prometheus remote write receiver

`kube-prometheus-stack` was upgraded to enable Prometheus remote write receiver, which is required for:

- collector metrics export
- Tempo metrics generator

### 3. Tempo and Loki

Tempo and Loki were deployed in namespace `observability`.

Final storage configuration:

- `gp3` volumes
- Loki single-binary mode
- TSDB schema
- retention configured in values

### 4. Gateway collector

The gateway collector was deployed in `deployment` mode and configured with:

- OTLP receivers
- `k8s_cluster`
- `k8sobjects`
- `k8sattributes`
- `resource`
- `tail_sampling`
- export to Tempo, Loki, and Prometheus remote write

### 5. Node collector

The node collector was deployed in `daemonset` mode and configured with:

- `filelog` receiver
- `kubeletstats` receiver
- export to the gateway collector

### 6. Auto-instrumented application

`bootcamp-api` was deployed from the local Helm chart and instrumented with the OpenTelemetry Operator using:

- `Instrumentation` CR in namespace `bootcamp`
- injected init container
- injected `NODE_OPTIONS`

## Main configuration changes made in this repo

### Terraform and storage

- `gp3` was standardized and managed from Terraform
- a Kubernetes `StorageClass` for `gp3` was defined through Terraform
- old `gp2` references were removed from observability values

### OpenTelemetry manifests

- fixed gateway collector cluster naming
- added explicit RBAC for `gateway-collector`
- added explicit RBAC for `node-collector`
- moved node collector telemetry port from `8888` to `8889`

### Loki

- upgraded from Loki `2.9.6` to Loki `3.6.7`
- enabled structured metadata
- fixed single-binary replica settings
- set `replication_factor: 1`

### Application

- fixed Helm chart image repository to match the ECR repository created by Terraform
- fixed app container port mismatch (`3000` instead of `8080`)
- added `/api/slow` endpoint to match the lab validation flow
- added request logging with `trace_id` and `span_id` for log correlation

### Ingress

- installed AWS Load Balancer Controller
- fixed ingress template backend port name
- added `ingressClassName: alb`

## Validation performed

### OpenTelemetry collectors

Verified collectors exist and are healthy:

```bash
kubectl -n observability get opentelemetrycollectors
```

Expected result:

- `gateway` in `deployment` mode
- `node` in `daemonset` mode

### Auto-instrumentation injection

Verified the app pod was actually mutated by the operator:

```bash
kubectl get pod -n bootcamp <pod> -o yaml | grep -E 'NODE_OPTIONS|otel-auto-instrumentation|opentelemetry'
```

Confirmed:

- init container present
- injected volume mount present
- `NODE_OPTIONS=--require ...autoinstrumentation.js`

### Application traffic

Validated endpoints:

```bash
curl -i http://$ALB/health
curl -i http://$ALB/api/hello
curl -i http://$ALB/api/slow
```

Confirmed:

- `/health` returns `200`
- `/api/hello` returns `200`
- `/api/slow` returns `200` and adds latency

### Collector internal metrics

Validated gateway collector receives telemetry:

```bash
curl -s localhost:8888/metrics | grep otelcol_receiver | head -n 20
```

Observed:

- accepted OTLP metric points
- accepted spans

### Tail sampling

Validated tail-sampling decisions:

```bash
curl -s localhost:8888/metrics | grep otelcol_processor_tail_sampling | head -n 10
```

Observed:

- `probabilistic` sampled traces
- `slow` sampled traces
- `errors` evaluated traces

### Tempo

Validated traces were available in Grafana Tempo and included `http.route=/api/slow`.

### Metrics

Validated OTel HTTP metrics existed in Prometheus/Grafana, including:

```promql
http_server_duration_milliseconds_count
```

### Logs

Validated the application emitted logs with trace correlation fields:

```bash
kubectl logs -n bootcamp <pod> --since=2m | grep 'route=/api/'
```

Observed lines such as:

```text
trace_id=... span_id=... method=GET route=/api/slow status=200
```

## Final outcome

The telemetry pipeline is working end to end:

- app traces are generated and visible in Tempo
- OTel metrics are exported and visible in Prometheus/Grafana
- app logs include `trace_id` and `span_id`
- slow requests are generated and observable
- both gateway and node collectors are healthy

## Blockers and lab inconsistencies

This lab required several fixes because the source instructions and the repository were not fully aligned.

Main blockers included:

- Loki chart/version mismatch for OTLP log ingestion
- invalid Node.js auto-instrumentation image tag
- missing AWS Load Balancer Controller prerequisite
- ingress backend misconfiguration
- application image repository mismatch with Terraform-created ECR
- application port mismatch
- missing `/api/slow` endpoint required by the lab
- missing RBAC for collectors
- node collector port conflict

Detailed blocker analysis and remediation notes are documented in:

- [deliverables/otel-day4-blockers.md](/home/ronald/projects/bootcamp-2026-4/day-14/deliverables/otel-day4-blockers.md)

## Useful commands

### Gateway metrics

```bash
kubectl -n observability port-forward svc/gateway-collector-monitoring 8888:8888
```

### Grafana

```bash
kubectl --namespace monitoring get secrets kube-prometheus-stack-grafana -o jsonpath="{.data.admin-password}" | base64 -d ; echo

export POD_NAME=$(kubectl --namespace monitoring get pod -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=kube-prometheus-stack" -oname)
kubectl --namespace monitoring port-forward $POD_NAME 3000:3000
```

### App traffic

```bash
for i in $(seq 1 50); do curl -s http://$ALB/api/hello >/dev/null; done
for i in $(seq 1 50); do curl -s http://$ALB/api/slow >/dev/null; done
```
