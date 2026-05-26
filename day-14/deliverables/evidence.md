# Day 14 — Evidence & Validation

## Evidence Collected

- OpenTelemetry Operator installed and running
- Gateway OpenTelemetryCollector deployed in `observability`
- Node OpenTelemetryCollector deployed in `observability`
- Tempo deployed and healthy
- Loki upgraded to `3.6.7` and healthy
- Prometheus remote write receiver enabled in `kube-prometheus-stack`
- Grafana datasources configured for Tempo and Loki
- `bootcamp-api` deployed from the local Helm chart
- Node.js auto-instrumentation injected into `bootcamp-api`
- ALB ingress created successfully through AWS Load Balancer Controller
- `/api/hello` and `/api/slow` responding through the ALB
- Traces visible in Tempo
- Metrics visible in Prometheus/Grafana
- Application logs emitted with `trace_id` and `span_id`
- Tail sampling decisions visible in collector internal metrics

## Validation Steps

### Operator and Collectors

```bash
kubectl -n observability get opentelemetrycollectors
kubectl -n observability get pods
```

Expected result:

- `gateway` collector healthy
- `node` collector healthy

### Auto-Instrumentation Injection

```bash
kubectl get pod -n bootcamp <pod> -o yaml | grep -E 'NODE_OPTIONS|otel-auto-instrumentation|opentelemetry'
```

Validated:

- injected init container
- injected `NODE_OPTIONS`
- injected instrumentation mount path

### Application Health

```bash
curl -i http://$ALB/health
curl -i http://$ALB/api/hello
curl -i http://$ALB/api/slow
```

Validated:

- `/health` returns `200`
- `/api/hello` returns `200`
- `/api/slow` returns `200`

### Collector Internal Metrics

```bash
kubectl -n observability port-forward svc/gateway-collector-monitoring 8888:8888
curl -s localhost:8888/metrics | grep otelcol_receiver | head -n 20
curl -s localhost:8888/metrics | grep otelcol_processor_tail_sampling | head -n 10
```

Validated:

- OTLP traffic accepted by the collector
- tail-sampling `probabilistic` decisions present
- tail-sampling `slow` decisions present

### Tempo Traces

Grafana validation:

- traces visible in Tempo
- traces for `/api/slow` visible
- trace attributes include route and status

### Prometheus Metrics

Grafana/Prometheus validation:

```promql
http_server_duration_milliseconds_count
```

Validated:

- OpenTelemetry HTTP metrics exist

### Correlated Application Logs

Pod log validation:

```bash
kubectl logs -n bootcamp <pod> --since=2m | grep 'route=/api/'
```

Validated:

- request logs contain `trace_id`
- request logs contain `span_id`
- `/api/hello` and `/api/slow` logs are emitted

## Notable Findings

- The technical telemetry pipeline works end to end.
- The lab itself had multiple inconsistencies that required fixes before the intended validation path worked.
- The most significant mismatches were:
  - Loki version incompatible with OTLP native logs
  - outdated Node.js auto-instrumentation image tag
  - missing AWS Load Balancer Controller prerequisite
  - missing `/api/slow` endpoint in the application
  - image repository mismatch between Helm values and Terraform-created ECR

Detailed notes are documented in:

- [otel-day4-blockers.md](/home/ronald/projects/bootcamp-2026-4/day-14/deliverables/otel-day4-blockers.md)

## Final Result

The lab was completed successfully after correcting the mismatches between the lab instructions, the chart, and the running cluster prerequisites.

Final verified state:

- OpenTelemetry collectors healthy
- application instrumented
- traces visible in Tempo
- metrics visible in Prometheus/Grafana
- logs emitted with trace correlation fields
- slow endpoint available and generating telemetry
