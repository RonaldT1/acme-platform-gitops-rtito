# Day 16 — Runbook

## Goal

Implement the Day 16 lab for:

- Cilium chained with AWS VPC CNI
- Hubble observability
- L7 `CiliumNetworkPolicy`

## Outcome

- repo cleaned from unrelated capstone assets
- base Terraform retained
- sample app aligned with the lab API paths
- base infrastructure recreated with Terraform
- AWS Load Balancer Controller and Karpenter installed successfully
- Cilium `1.19.4` installed in chained mode with Hubble enabled
- `bootcamp-api` and `bootcamp-frontend` deployed successfully
- L7 policy behavior confirmed with real application traffic

## Explanation Notes

- `bootcamp-frontend` exists as a traffic source for the lab, not as a real frontend application.
- The L7 `CiliumNetworkPolicy` allows requests to `bootcamp-api` only from pods that match the expected source identity.
- In this repo, that identity is represented by the pod labels on `Deployment/bootcamp-frontend` in `bootcamp-excess-media`.
- This is important for the explanation later: Cilium is not evaluating only HTTP paths and methods, it is also evaluating who is sending the traffic.
- Initial Cilium install hit two Helm validation issues inherited from older values conventions:
  - `proxy.prometheus.enabled` is removed in Cilium `1.16+`
  - `ServiceMonitor` settings require Prometheus Operator CRDs, which this lab does not install by default
- The practical fix was to simplify `cilium-values.yaml` so it matches Cilium `1.19.4` and does not depend on `monitoring.coreos.com` CRDs.
- `cilium status --wait` also failed locally because the `cilium` CLI is not installed in the workstation environment, even though the in-cluster rollout completed successfully.
- The first L7 policy verification gave a false negative on `DELETE /api/items/1` because the app pods were created before Cilium was installed.
- In chained mode, existing pods keep the old network setup until they are recreated, so `bootcamp-api` and `bootcamp-frontend` had to be restarted after the Cilium install.
- The initial `POST /api/login` test returned `400` because the request body was sent as form data instead of JSON; that was an application input issue, not a Cilium policy issue.
- After restarting both deployments and sending JSON correctly, the expected behavior was confirmed:
  - `GET /api/items` -> `200`
  - `POST /api/login` -> `200`
  - `DELETE /api/items/1` -> `403`

## Final Validation

- `cilium` DaemonSet healthy on all nodes
- `hubble-relay` and `hubble-ui` healthy
- `aws-node` healthy alongside Cilium
- `api-l7` policy valid
- `bootcamp-api` visible in `cilium endpoint list` with ingress enforcement enabled
- AWS Load Balancer Controller logs showed normal controller startup

## Remaining Gaps

- `cilium status --wait` was not captured because the `cilium` CLI is missing locally
- `hubble observe` was not captured because the `hubble` CLI is missing locally
- Hubble ingress through ALB was prepared but not completed because hostname and ACM certificate selection were treated as environment-specific work outside the core lab path
