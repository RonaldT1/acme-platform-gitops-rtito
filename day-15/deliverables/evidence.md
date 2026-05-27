# Day 15 — Evidence

## Core Platform Rebuilt

- EKS cluster recreated successfully from Terraform
- managed node group healthy
- ALB Controller installed and reconciling ingress
- Karpenter installed and `NodePool` / `EC2NodeClass` applied
- Argo Rollouts installed and healthy
- `kube-prometheus-stack` installed with Prometheus remote write receiver enabled
- OpenTelemetry Operator, Tempo, Loki, and collectors healthy

## Application Validation

- `bootcamp-api` image rebuilt and pushed to ECR:
  - `711387135481.dkr.ecr.us-east-1.amazonaws.com/bootcamp-rtito-day15-api:day15-base`
- `bootcamp-api` deployed and healthy
- ALB ingress created successfully
- endpoints verified:
  - `/health`
  - `/api/hello`
  - `/api/slow`
- OpenTelemetry auto-instrumentation confirmed through injected `NODE_OPTIONS` and init container

## GitOps / ArgoCD

- ArgoCD reinstalled in the cluster
- `bootcamp-api` `Application` created successfully
- ArgoCD source of truth uses the separate GitOps repo:
  - `https://github.com/RonaldT1/ronald-bootcamp-gitops`
- final ArgoCD application status:
  - `Synced`
  - `Healthy`

## Kyverno

- Kyverno installed successfully
- policy-reporter installed successfully
- five `ClusterPolicy` resources applied in `Audit` mode
- namespace owner policy tuned to reduce system namespace noise
- `bootcamp-api` workload reports passed policy checks

## Backstage

- Backstage installed successfully with PostgreSQL
- internal ALB ingress created
- guest auth enabled for lab validation
- Backstage UI reachable through local access / port-forward
- `bootcamp-api` visible in the catalog UI
- catalog metadata stored in the GitOps repo as `catalog-info.yaml`

## Validation Notes

- Direct unauthenticated API checks against Backstage returned `401` until guest auth was enabled.
- Backstage was validated through UI access rather than only anonymous API requests.
- Kyverno remained in `Audit`, not `Enforce`, to preserve deployability while evaluating real violations.
