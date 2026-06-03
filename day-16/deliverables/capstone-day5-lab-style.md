# Day 16 — Lab Walkthrough

## Context

This lab focused on adding Cilium and Hubble to an EKS cluster that still keeps AWS VPC CNI active, then proving L7 policy enforcement against the sample API.

## What Was Prepared

- inherited capstone-specific manifests were removed from the repo
- the Terraform and Karpenter naming were normalized to `day16`
- the sample Node app was updated to expose the endpoints required by the lab
- minimal Kubernetes manifests were added for:
  - `bootcamp-api`
  - `bootcamp-frontend`
  - `bootcamp-excess-media`

## Cilium Installation

Cilium `1.19.4` was installed in chained mode with AWS VPC CNI still running. During the first Helm attempts, the values file had to be corrected because it still contained deprecated options removed in Cilium `1.16+` and `ServiceMonitor` settings that assumed Prometheus Operator CRDs.

After those changes:

- `cilium` DaemonSet became healthy on all nodes
- `cilium-operator` became healthy
- `hubble-relay` became healthy
- `hubble-ui` became healthy
- `aws-node` remained healthy

## Hubble

Hubble Relay and Hubble UI were installed successfully as part of the Cilium chart. The ingress manifest for exposing Hubble UI through ALB was prepared, but the final HTTPS exposure was left outside the completed scope because it requires an approved hostname and ACM certificate mapping for the environment.

## L7 Policy

The `CiliumNetworkPolicy` named `api-l7` was applied in namespace `bootcamp-excess-media` and validated as `True`.

The policy allows:

- `GET /api/*`
- `POST /api/login`
- `GET /healthz`

And it rejects:

- `DELETE /api/*`

## Traffic Validation

Traffic was generated from `Deployment/bootcamp-frontend` to `Service/bootcamp-api`.

The first verification attempt was misleading because the workloads had been created before Cilium was installed. After restarting both deployments, the expected behavior appeared:

- `GET /api/items` -> `200`
- `POST /api/login` -> `200`
- `DELETE /api/items/1` -> `403`

This was the key proof that L7 policy enforcement was working.

## Notes

- `bootcamp-frontend` exists in this repo as a traffic source for policy validation, not as a real user-facing frontend.
- `cilium status --wait` and `hubble observe` were not captured because the local workstation did not have the `cilium` and `hubble` CLIs installed.
