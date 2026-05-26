# OpenTelemetry Day 4 - Blockers and Notes

## Blocker: Loki version mismatch with OTLP ingestion

The lab's Step 3 config sends logs from the OpenTelemetry Collector to Loki using the native OTLP HTTP endpoint:

`POST /otlp/v1/logs`

However, the Loki installation command in the lab used:

```bash
helm upgrade --install loki grafana/loki \
  --namespace observability \
  --version 5.47.1 \
  -f loki-values.yaml
```

That deployment produced Loki `2.9.6`, not Loki `3.x`.

This is a lab inconsistency because native OTLP log ingestion in Loki is a Loki `3.0+` capability. On Loki `2.9.6`, the collector reaches the service but receives `HTTP 404` on `/otlp/v1/logs`.

## Evidence

- `helm` output showed `Loki version: 2.9.6`
- `gateway-collector` logs showed:

```text
request to http://loki.observability.svc.cluster.local:3100/otlp/v1/logs responded with HTTP Status Code 404
```

## Conclusion

The collector configuration was correct for the lab design, but the Loki version installed by the lab command was not compatible with that design.

This should be treated as a lab/source-of-truth issue, not as an implementation bug in the collector manifest.

## Recommended remediation

Because Loki was freshly installed for the lab and there is no valuable persisted log history to preserve, the cleanest path is:

1. Uninstall the current Loki release.
2. Delete the Loki PVC created for the incompatible deployment.
3. Install a Loki `3.x` release.
4. Keep `schema: v13` and `store: tsdb`.
5. Set `limits_config.allow_structured_metadata: true`.
6. Re-validate OTLP log export from `gateway-collector`.

## What was actually changed

The following fixes were required to make the lab consistent with Loki `3.x` in single-binary mode:

1. Upgrade from `grafana/loki` chart `5.47.1` to `grafana/loki` chart `6.55.0`.
2. Confirm that the new release runs Loki `3.6.7`.
3. Keep Loki in single-binary mode and explicitly disable simple-scalable replicas:
   - `backend.replicas: 0`
   - `read.replicas: 0`
   - `write.replicas: 0`
   - `singleBinary.replicas: 1`
4. Enable structured metadata support:
   - `loki.limits_config.allow_structured_metadata: true`
5. Set single-replica replication correctly for monolithic mode:
   - `loki.commonConfig.replication_factor: 1`

## Secondary issue after upgrading Loki

After moving to Loki `3.x`, the original `404` disappeared, but the collector then failed with:

```text
HTTP Status Code 503, Message=at least 2 live replicas required, could only find 1
```

This was not an OTLP endpoint problem anymore. It was a Loki single-replica configuration issue. The fix was to set:

```yaml
loki:
  commonConfig:
    replication_factor: 1
```

This matches Grafana's official monolithic installation guidance for a single replica.

## Validation criteria used

The Step 3 collector path should be considered healthy only when all of the following are true:

1. `gateway-collector` no longer shows RBAC `forbidden` errors.
2. `gateway-collector` no longer shows `404` on `/otlp/v1/logs`.
3. `gateway-collector` no longer shows `503` requiring more live replicas than the deployment actually has.
4. Loki is running as the intended topology for the lab.

## Step 4 issue: node collector CrashLoopBackOff

After Step 3 was stabilized, the `node-collector` DaemonSet was still failing.

Two independent problems were found:

1. Telemetry port conflict inside the collector process:

```text
listen tcp :8888: bind: address already in use
```

2. Missing RBAC for the `kubeletstats` receiver:

```text
403 Forbidden
Forbidden (user=system:serviceaccount:observability:node-collector, verb=get, resource=nodes, subresource=stats)
```

## Step 4 remediation applied

The following changes were made:

1. Move the DaemonSet collector self-telemetry endpoint away from `8888` to `8889`.
2. Add cluster-level RBAC for the `node-collector` ServiceAccount so it can read:
   - `nodes`
   - `nodes/proxy`
   - `nodes/stats`
   - `nodes/metrics`
   - `pods`

## Files changed for Step 4

- `exercises/aws-bootcamp/k8s/otel/collector-daemonset.yaml`
- `exercises/aws-bootcamp/k8s/otel/node-rbac.yaml`

## Step 4 validation outcome

After applying the DaemonSet update and RBAC:

1. The previous `bind: address already in use` error disappeared.
2. The previous `403 Forbidden` error on `nodes/stats` disappeared.
3. The `node-collector` pods became healthy.

## Step 5 issue: Node.js auto-instrumentation image tag was invalid

When the `bootcamp-api` workload was finally deployed, pods failed during the init container stage with:

```text
ghcr.io/open-telemetry/opentelemetry-operator/autoinstrumentation-nodejs:0.50.0: not found
```

This means the image tag pinned in the lab/repo was no longer available in GHCR.

## Step 5 remediation applied

The `Instrumentation` manifest was updated to use an official published tag that exists in the upstream package registry:

- `ghcr.io/open-telemetry/opentelemetry-operator/autoinstrumentation-nodejs:0.76.0`

This was verified against the official GitHub Container Registry package page for the OpenTelemetry Operator Node.js auto-instrumentation image.

## Step 7 prerequisite gap: AWS Load Balancer Controller was not installed

The lab expects traffic to reach the application through an ALB-backed Kubernetes `Ingress`, but the cluster did not have `aws-load-balancer-controller` installed.

Symptoms:

- `kubectl get ingress -n bootcamp` showed an ingress object with no usable endpoint at first.
- `kubectl get pods -n kube-system | grep aws-load-balancer-controller` returned nothing.
- `kubectl logs -n kube-system deploy/aws-load-balancer-controller` initially failed because the deployment did not exist.

## Step 7 remediation applied

The AWS Load Balancer Controller was installed using the IAM role already provisioned by Terraform for IRSA.

After installation, the controller reconciled the ingress and created the ALB successfully.

## Step 7 ingress template issue

Even after the controller was installed, the chart ingress template still produced an invalid ALB listener rule.

The controller logs showed:

```text
Backend action does not exist
```

This happened because the ingress backend referenced:

```yaml
port:
  name: use-annotation
```

but the chart services expose the backend using port name `http`.

## Step 7 ingress remediation applied

The ingress template was corrected to:

1. Set `spec.ingressClassName: alb`
2. Use the real service port name:

```yaml
port:
  name: http
```

## Files changed for Step 7

- `exercises/aws-bootcamp/k8s/charts/bootcamp-api/templates/ingress.yaml`

## Operational note

There is no need to delete Loki pods manually if `helm uninstall` is used. Helm will remove the managed workload objects. The storage should be cleaned only if the lab does not require preserving previous Loki data.
