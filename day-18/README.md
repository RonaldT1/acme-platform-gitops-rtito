# Day-17

## Overview

Day 17 completed Istio Ambient mode on top of the rebuilt Day 16 baseline:

- EKS `bootcamp-rtito-day17-eks`
- Cilium `1.19.4` in chained mode with AWS VPC CNI
- Istio `1.30.0` installed by Helm
- namespace `bootcamp-prod` enrolled in Ambient mode
- waypoint proxy enabled for L7 routing
- `PeerAuthentication` STRICT mTLS
- `bootcamp-api` deployed as `v1` and `v2`
- weighted traffic split `90/10`
- 2-second fault injection on a subset of requests

## Outcome

The lab worked end to end with these verified results:

- `ztunnel`, `istio-cni-node`, and `istiod` healthy
- `bootcamp-prod` labeled with `istio.io/dataplane-mode=ambient`
- waypoint `bootcamp-prod-waypoint` programmed successfully
- `PeerAuthentication` mode `STRICT`
- traffic split observed from in-mesh client:
  - first run: `v1=86  v2=14`
  - second run: `v1=93  v2=7`
- non-mesh client rejected:
  - HTTP code `000`
  - curl exit code `56`
- fault injection confirmed from waypoint logs with `DI` and latencies around `1996-2009 ms`

## Important Notes

- The `slow_2s` counter from the shell script stayed at `0`, but the waypoint logs proved that delay injection was active.
- `istioctl` was not available locally, so waypoint enrollment was done with Gateway API resources and labels instead.
- `hubble observe` was not captured because the local Hubble CLI was not verified as available.

## References

- Steps: [CAPSTONE-STEPS.md](/home/ronald/projects/bootcamp-2026-4/day-17/CAPSTONE-STEPS.md)
- Evidence: [evidence.md](/home/ronald/projects/bootcamp-2026-4/day-17/deliverables/evidence.md)
- Commands: [commands.md](/home/ronald/projects/bootcamp-2026-4/day-17/notes/commands.md)
