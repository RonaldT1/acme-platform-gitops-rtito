# Day 15 — Capstone: Kyverno policies + Backstage developer portal

## Overview

This capstone rebuilt the full platform base from zero after `terraform destroy`, then added:

- Kyverno in `Audit` mode
- policy-reporter
- Backstage
- ArgoCD integration using a separate GitOps repo
- catalog metadata for `bootcamp-api`

The final platform includes:

- EKS + managed node group
- AWS Load Balancer Controller
- Karpenter
- Argo Rollouts
- kube-prometheus-stack
- OpenTelemetry Operator + collectors
- Tempo + Loki
- `bootcamp-api` deployed and auto-instrumented
- ArgoCD syncing from the GitOps repo
- Kyverno guardrails and compliance reports
- Backstage developer portal

## Important Notes

- Kyverno was intentionally kept in `Audit` mode during implementation to avoid breaking platform components while validating real violations.
- Backstage was validated through internal access / port-forward and guest auth for the lab flow.
- Backstage used a public image, so the `only-org-ecr` policy reports expected `Audit` findings for that namespace.
- ArgoCD does not use this repo as its source of truth. It syncs from the separate GitOps repo:
  - `https://github.com/RonaldT1/ronald-bootcamp-gitops`

## Main Result

`bootcamp-api` is:

- deployed on the rebuilt cluster
- exposed through ALB
- instrumented with OpenTelemetry
- managed by ArgoCD from the GitOps repo
- represented in Backstage catalog metadata
- covered by Kyverno policy reporting

## References

- Implementation runbook:
  - [capstone-day5-runbook.md](/home/ronald/projects/bootcamp-2026-4/day-15/deliverables/capstone-day5-runbook.md)
- Evidence:
  - [evidence.md](/home/ronald/projects/bootcamp-2026-4/day-15/deliverables/evidence.md)
- Commands:
  - [commands.md](/home/ronald/projects/bootcamp-2026-4/day-15/notes/commands.md)
- Known issues / blockers:
  - [otel-day4-blockers.md](/home/ronald/projects/bootcamp-2026-4/day-15/deliverables/otel-day4-blockers.md)
