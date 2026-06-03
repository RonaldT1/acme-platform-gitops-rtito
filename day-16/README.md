# Day 16 — Cilium CNI + eBPF + Hubble + L7 NetworkPolicy

## Overview

This lab rebuilt the minimum AWS/EKS platform state required to validate:

- Cilium in chained mode with AWS VPC CNI
- Hubble observability
- L7 `CiliumNetworkPolicy`
- traffic validation against the `bootcamp-api` application

## Result

- EKS, ALB Controller, and Karpenter were recreated successfully
- Cilium `1.19.4` was installed in chained mode
- `aws-node` remained healthy alongside Cilium
- Hubble Relay and Hubble UI became healthy
- the application and frontend test client were deployed in `bootcamp-excess-media`
- the L7 policy was validated successfully:
  - `GET /api/items` -> `200`
  - `POST /api/login` -> `200`
  - `DELETE /api/items/1` -> `403`

## Notes

- Hubble ingress via ALB was prepared but not completed because it needs an environment-approved hostname and ACM certificate mapping.
- `cilium` and `hubble` CLIs were not installed locally, so `cilium status` and `hubble observe` were not captured from the workstation.

## References

- Steps: [CAPSTONE-STEPS.md](/home/ronald/projects/bootcamp-2026-4/day-16/CAPSTONE-STEPS.md)
- Evidence: [evidence.md](/home/ronald/projects/bootcamp-2026-4/day-16/deliverables/evidence.md)
- Commands: [commands.md](/home/ronald/projects/bootcamp-2026-4/day-16/notes/commands.md)
