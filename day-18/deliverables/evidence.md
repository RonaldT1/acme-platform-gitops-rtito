# Day-17

## Platform Health

- `kubectl -n kube-system get ds aws-node` showed `4/4` ready
- `kubectl -n kube-system get ds cilium` showed `4/4` ready
- `kubectl -n kube-system get deploy cilium-operator hubble-relay hubble-ui` showed all ready
- `kubectl get nodepool` showed `general=True` and `gpu=True`
- `kubectl get ec2nodeclass` showed `default=True`

## Istio Ambient Health

- `kubectl -n istio-system get ds ztunnel istio-cni-node`
  - `ztunnel 4/4`
  - `istio-cni-node 4/4`
- `kubectl -n istio-system get deploy istiod`
  - `istiod 2/2`
- `kubectl get ns bootcamp-prod -L istio.io/dataplane-mode,istio.io/use-waypoint`
  - `bootcamp-prod ambient bootcamp-prod-waypoint`
- `kubectl -n bootcamp-prod get gateway bootcamp-prod-waypoint`
  - `PROGRAMMED=True`

## Application And Security

- `kubectl -n bootcamp-prod get pods,svc,peerauthentication,authorizationpolicy,destinationrule,virtualservice`
  - `bootcamp-api-v1` running
  - `bootcamp-api-v2` running
  - `bootcamp-prod-waypoint` running
  - service `bootcamp-api` on `3000/TCP`
  - `PeerAuthentication/default` mode `STRICT`
  - `AuthorizationPolicy/api-allow-frontend` present
  - `DestinationRule/bootcamp-api` present
  - `VirtualService/bootcamp-api` present

## Traffic Validation

- In-mesh traffic split from `load-tester`:
  - run 1: `v1=86  v2=14  slow_2s=0`
  - run 2: `v1=93  v2=7  slow_2s=0`
- Non-mesh client rejection from namespace `no-mesh`:
  - HTTP code `000`
  - `exit_code=56`

## Fault Injection Evidence

Waypoint logs confirmed delay injection with `DI` and ~2-second durations, for example:

- `200 DI ... 2005`
- `200 DI ... 1997`
- `200 DI ... 2001`
- `200 DI ... 2009`

This is the accepted proof that the `VirtualService` delay rule was active even though the shell counter `slow_2s` did not increment.

## Blockers And Workarounds

- Gateway API `standard-install.yaml` and `experimental-install.yaml` both failed to create `tlsroutes.gateway.networking.k8s.io` because the cluster rejected the `isIP` CEL validation.
- Istio installation still proceeded because the lab used waypoint/Gateway API resources and did not depend on `TLSRoute`.
- `ztunnel` initially failed readiness with `Unauthenticated` until `global.multiCluster.clusterName: bootcamp-eks` was added to `istiod-values.yaml`.
- `istioctl` was not installed locally, so waypoint creation used a manual `Gateway` plus namespace label.
- `hubble observe` and `istioctl ztunnel-config workload` were not captured because the required CLIs were not available locally.
