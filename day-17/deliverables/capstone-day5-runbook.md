# Day-17

## Runbook Summary

This repo completed Istio Ambient mode on top of the Day 16 Cilium baseline.

### Completed Scope

- Terraform rebuilt the `day17` infrastructure
- application image published as `v1` and `v2`
- Cilium and Hubble restored successfully
- Istio Ambient installed with Helm
- namespace `bootcamp-prod` enrolled into Ambient mode
- waypoint created manually with Gateway API resources
- `PeerAuthentication` STRICT enforced
- `AuthorizationPolicy` limited access to:
  - `cluster.local/ns/bootcamp-excess-media/sa/frontend`
  - `cluster.local/ns/bootcamp-prod/sa/load-tester`
- `VirtualService` split traffic `90/10` and applied delay injection

### Final Validation

- in-mesh requests reached both versions
- out-of-mesh request failed with `000` / `56`
- waypoint logs showed `DI` and ~2-second delays

### Residual Gaps

- `istioctl` CLI missing locally
- `hubble` CLI not confirmed locally
- Gateway API `TLSRoute` CRD failed in this Kubernetes environment
