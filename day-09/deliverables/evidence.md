# Day 09 - Evidence & Validation

## Problem Encountered

The application was correctly instrumented with Prometheus metrics using the `prom-client` library, including the `http_requests_total` counter.

However, during the verification phase, the pods deployed in Kubernetes were still running an older container image that did not include the updated instrumentation code. Because of this, the query:

```promql
sum(rate(http_requests_total[1m])) by (status)
```

did not return results.

---

## Solution & Validation Strategy

Despite the outdated image issue, the monitoring stack was successfully validated using runtime metrics such as:

```promql
process_resident_memory_bytes
```

This confirmed that:

✅ Prometheus was correctly scraping metrics
✅ The ServiceMonitor was working correctly
✅ Grafana was correctly connected to Prometheus
✅ Metrics visualization was working end-to-end
✅ The observability pipeline in Kubernetes was operational

---

## Verification Steps Performed

### Prometheus Verification

#### Port-Forward Command

```bash
kubectl -n monitoring port-forward svc/kps-kube-prometheus-stack-prometheus 9090:9090
```

#### UI Access

```
http://localhost:9090/targets
```

**Expected Results:**
- All targets in `UP` state
- ServiceMonitor targets listed
- Scraping interval confirmation

---

### Grafana Verification

#### Port-Forward Command

```bash
kubectl -n monitoring port-forward svc/kps-grafana 3001:80
```

#### UI Access

```
http://localhost:3001
```

#### Default Credentials

```
Username: admin
Password: bootcamp-2026
```

**Expected Results:**
- Prometheus datasource connected
- Dashboards displaying metrics
- Real-time data updates
- Time Series visualization working

---

## Traffic Generation & Testing

Generated 200 requests to the application:

```bash
for i in {1..200}; do
  curl -s http://$ALB/api/hello > /dev/null
done
```

**Results:**
- Requests successfully processed
- Application responding on `/api/hello` endpoint
- Load Balancer correctly routing traffic

---

## Metrics Captured

### Runtime Metrics (Validated)

- `process_resident_memory_bytes` - Memory usage tracking
- `process_cpu_seconds_total` - CPU usage
- `nodejs_heap_objects_total` - Heap memory statistics

### Custom Metrics (Code Present, Image Update Pending)

- `http_requests_total` - HTTP request counter by status

---

## Infrastructure Cleanup

Infrastructure was successfully destroyed:

```bash
terraform -chdir=infra destroy
```

**Result:** Destroy complete! Resources: 28 destroyed.

---

## Key Learnings Documented

1. **Application Instrumentation:** Successfully implemented Prometheus metrics in Node.js using `prom-client`
2. **Kubernetes Integration:** ServiceMonitor correctly configured for metric scraping
3. **Grafana Dashboards:** Successfully created and configured dashboards for visualization
4. **End-to-End Flow:** Validated complete pipeline from application → metrics export → Prometheus → Grafana
5. **Image Management:** Highlighted the importance of rebuilding and redeploying container images with code changes
6. **Container Versioning:** Demonstrated the difference between local development code and deployed container images
7. **Observability Architecture:** Confirmed the operational readiness of the entire observability stack

---

## Recommendations for Next Steps

1. **Rebuild and Push Image:** Recompile the Docker image with updated `prom-client` instrumentation code
2. **Redeploy Application:** Update the Kubernetes deployment with the new image tag
3. **Validate Custom Metrics:** Run the traffic generation again and verify `http_requests_total` in Prometheus
4. **Create Custom Dashboards:** Build specific dashboards for custom application metrics
5. **Set Alerts:** Configure alerting rules based on custom metrics thresholds
