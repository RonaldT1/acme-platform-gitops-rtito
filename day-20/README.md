# Day-19

## Overview

Day 19 adds runtime security controls on top of the existing bootcamp cluster:

- Falco `0.44.0` with chart `9.0.0`
- `modern_ebpf` Falco driver
- Falcosidekick forwarding to Alertmanager
- a custom Falco rule for shell spawns inside `bootcamp-prod`
- Tetragon `1.7.0` with a namespaced `TracingPolicy`
- in-kernel enforcement that kills `/bin/sh` and `/bin/bash` in `bootcamp-prod`

This repo now includes the manifests and Helm values required for the lab under:

- [exercises/aws-bootcamp/infra/falco-values.yaml](/home/ronald/projects/bootcamp-2026-4/day-19/exercises/aws-bootcamp/infra/falco-values.yaml)
- [exercises/aws-bootcamp/infra/falco-values-extra.yaml](/home/ronald/projects/bootcamp-2026-4/day-19/exercises/aws-bootcamp/infra/falco-values-extra.yaml)
- [exercises/aws-bootcamp/infra/tetragon-values.yaml](/home/ronald/projects/bootcamp-2026-4/day-19/exercises/aws-bootcamp/infra/tetragon-values.yaml)
- [exercises/aws-bootcamp/k8s/falco/rules/bootcamp-shell-in-container.yaml](/home/ronald/projects/bootcamp-2026-4/day-19/exercises/aws-bootcamp/k8s/falco/rules/bootcamp-shell-in-container.yaml)
- [exercises/aws-bootcamp/k8s/observability/alertmanager-route-falco.yaml](/home/ronald/projects/bootcamp-2026-4/day-19/exercises/aws-bootcamp/k8s/observability/alertmanager-route-falco.yaml)
- [exercises/aws-bootcamp/k8s/tetragon/tp-block-shell.yaml](/home/ronald/projects/bootcamp-2026-4/day-19/exercises/aws-bootcamp/k8s/tetragon/tp-block-shell.yaml)

## Goal

The lab target is:

- detect a shell spawned in any `bootcamp-prod` container with Falco
- route that event to Alertmanager through Falcosidekick
- kill `/bin/sh` or `/bin/bash` in `bootcamp-prod` with Tetragon
- prove a `kubectl exec` shell attempt ends with exit code `137`

## Notes

- This day assumes the existing EKS/Cilium/Istio/Kyverno baseline is already running.
- The evidence files in this repo were converted from stale `day-18` content into templates/checklists; actual command output still needs to be captured from the live cluster.

## References

- Steps: [CAPSTONE-STEPS.md](/home/ronald/projects/bootcamp-2026-4/day-19/CAPSTONE-STEPS.md)
- Evidence: [evidence.md](/home/ronald/projects/bootcamp-2026-4/day-19/deliverables/evidence.md)
- Commands: [commands.md](/home/ronald/projects/bootcamp-2026-4/day-19/notes/commands.md)
