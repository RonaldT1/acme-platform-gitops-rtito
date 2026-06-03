# Day 16 — Evidence

## Platform Status

- `terraform apply` completed successfully
- AWS Load Balancer Controller rolled out successfully
- Karpenter rolled out successfully
- `NodePool` resources `general` and `gpu` were `Ready`
- `EC2NodeClass/default` was `Ready`

## Cilium And Hubble

- `kubectl -n kube-system get ds cilium`:
  - `4/4` ready
- `kubectl -n kube-system get deploy hubble-relay hubble-ui`:
  - `hubble-relay 1/1`
  - `hubble-ui 1/1`
- `kubectl -n kube-system get ds aws-node`:
  - `4/4` ready
- `kubectl exec -n kube-system ds/cilium -- cilium endpoint list | head -20` showed `bootcamp-api` managed by Cilium with ingress enforcement enabled

## Application And Policy

- `bootcamp-api` deployed successfully in `bootcamp-excess-media`
- `bootcamp-frontend` deployed successfully in `bootcamp-excess-media`
- `kubectl -n bootcamp-excess-media get ciliumnetworkpolicy`:
  - `api-l7` valid
- L7 policy behavior validated from `bootcamp-frontend` to `bootcamp-api`:
  - `GET /api/items` -> `200`
  - `POST /api/login` -> `200`
  - `DELETE /api/items/1` -> `403`

## Current Blockers And Notes

- The first Cilium Helm install attempts failed because the values file still included deprecated or incompatible options for Cilium `1.19.4`.
- Specifically:
  - `proxy.prometheus.enabled` was removed in Cilium `1.16+`
  - `ServiceMonitor` options require Prometheus Operator CRDs that are not present in this lab baseline
- The Cilium release was installed successfully after removing those options from `infra/cilium-values.yaml`.
- `cilium status --wait` could not run because the `cilium` CLI is not installed on the local machine:
  - `/bin/bash: cilium: command not found`
- `hubble observe` could not be captured because the `hubble` CLI is also not installed locally.
- `kubectl -n kube-system exec ds/cilium -- cilium metrics list | grep hubble_drop` returned no matching line during capture.
- The first policy test attempt was misleading until the workloads were restarted after the Cilium install.
- This matters because chained mode affects new or recreated pods; existing pods do not automatically pick up the Cilium-managed network path.
- Hubble ingress through ALB was intentionally left incomplete because it requires an environment-approved hostname and ACM certificate mapping.
