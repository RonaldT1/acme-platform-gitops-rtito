# Day-17

## High-Level Steps

1. Renamed the inherited `day16` baseline to `day17` across Terraform and Kubernetes manifests.
2. Recreated the AWS baseline with Terraform using the new `day17` state and naming.
3. Rebuilt and pushed the application image as:
   - `bootcamp-rtito-day17-api:v1`
   - `bootcamp-rtito-day17-api:v2`
4. Restored the Day 16 platform baseline:
   - AWS Load Balancer Controller
   - Karpenter
   - Cilium chained mode
   - Hubble
5. Updated the application to expose `/api/version` while keeping port `3000`.
6. Installed Istio `1.30.0` with Helm:
   - `istio-base`
   - `istiod`
   - `istio-cni`
   - `ztunnel`
7. Fixed the initial `ztunnel` authentication failure by aligning Istio `clusterName` to `bootcamp-eks` in both control plane and dataplane values.
8. Enabled Ambient mode on namespace `bootcamp-prod`.
9. Created a waypoint with Gateway API resources because `istioctl` was not installed locally.
10. Deployed `bootcamp-api` `v1` and `v2` in `bootcamp-prod`.
11. Applied:
   - `PeerAuthentication` STRICT
   - `AuthorizationPolicy`
   - `DestinationRule`
   - `VirtualService`
12. Validated:
   - `STRICT` mTLS blocks `no-mesh`
   - weighted routing reaches both `v1` and `v2`
   - fault injection adds ~2 seconds to some requests

## Real Blockers

- Gateway API `v1.5.1` failed to create `TLSRoute` in this environment because the cluster rejected the `isIP` CEL validation.
- `ztunnel` initially stayed `0/1` because it claimed cluster `bootcamp-eks` while `istiod` still knew the local cluster as `Kubernetes`.
- `istioctl` was missing locally, so the waypoint had to be created manually with `kubectl`.
- `slow_2s` from the shell validation script did not reflect the injected delay, so the final proof came from waypoint logs.
