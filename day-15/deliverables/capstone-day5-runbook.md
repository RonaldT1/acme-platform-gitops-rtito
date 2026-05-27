# Day 15 — Capstone Runbook

## Goal

Rebuild the platform from zero after `terraform destroy`, then implement:

- Kyverno guardrails
- policy-reporter
- Backstage
- catalog metadata
- ArgoCD-backed service visibility

## Starting Reality

The repo was not a fresh Day 15 implementation.

It was effectively a cleaned-up copy of Day 14, so the real work began with:

- repository cleanup
- Day 14 hardcode removal
- Terraform re-apply
- full prerequisite reconstruction

## 1. Repository Cleanup

Removed:

- local Terraform state artifacts
- `.terraform` leftovers
- old `.bak` chart files
- legacy `cluster-autoscaler.tf`
- old Day 14-only notes content

Kept:

- Terraform for VPC/EKS/ECR/Karpenter IAM
- application chart
- OpenTelemetry manifests
- Karpenter manifests

## 2. Day 15 Hardcode Alignment

Updated:

- Terraform backend key to `day-15`
- project naming to `bootcamp-rtito-day15`
- Karpenter cluster naming
- OTel cluster resource naming
- application ECR repository naming

## 3. Rebuild Base Infrastructure

Ran Terraform successfully to recreate:

- VPC
- subnets
- NAT
- EKS cluster
- managed node group
- ECR for `bootcamp-api`
- OIDC provider
- ALB controller IAM
- Karpenter IAM + interruption queue
- EBS CSI addon
- default `gp3` storage class

## 4. Rebuild Cluster Platform

Installed in this order:

1. AWS Load Balancer Controller
2. Karpenter
3. Argo Rollouts
4. `kube-prometheus-stack`
5. OpenTelemetry Operator
6. Tempo
7. Loki

## 5. Karpenter Adjustment

An older Karpenter version was initially attempted but conflicted with the manifests.

Final working approach:

- install `karpenter-crd`
- install Karpenter `1.0.11`
- keep manifests on `v1`

Applied:

- `EC2NodeClass`
- `NodePool general`
- `NodePool gpu`

## 6. Observability Stack

Installed and validated:

- OTel Operator
- gateway collector
- node collector
- Tempo
- Loki
- Prometheus remote write receiver

Applied:

- collector RBAC
- collector manifests
- instrumentation manifest

## 7. Application Rebuild

Rebuilt and pushed:

- `711387135481.dkr.ecr.us-east-1.amazonaws.com/bootcamp-rtito-day15-api:day15-base`

Updated chart values to use:

- correct Day 15 ECR repository
- real tag `day15-base`

Deployed:

- `bootcamp-api`

Validated:

- rollout healthy
- ALB ingress created
- `/health`
- `/api/hello`
- `/api/slow`
- auto-instrumentation injected

## 8. ArgoCD Rebuild

ArgoCD was not present in the rebuilt cluster.

Installed ArgoCD again, then connected it to the separate GitOps repo:

- `https://github.com/RonaldT1/ronald-bootcamp-gitops`

Important implementation note:

- this repo is not the GitOps source of truth
- the GitOps repo contains the chart ArgoCD watches

Fixed:

- `Application` path confusion
- GitOps image values
- catalog metadata location

Validated final state:

- `bootcamp-api` application `Synced`
- `bootcamp-api` application `Healthy`

## 9. Kyverno Implementation

Created and applied:

- `disallow-latest-tag`
- `require-requests-limits`
- `only-org-ecr`
- `disallow-privileged`
- `require-namespace-owner`

Installed:

- Kyverno
- policy-reporter

Kept policies in `Audit`, not `Enforce`, because:

- platform charts still generate expected findings
- Backstage used a public image for implementation speed
- the lab benefits from measuring real violations before enforcement

Tuned:

- `require-requests-limits` excludes `karpenter`
- namespace owner policy excludes system namespaces

Labeled owned namespaces with:

- `owner=team-platform`

## 10. Backstage Implementation

Prepared:

- cluster-wide RBAC
- service account token secret
- Kubernetes plugin credentials
- ArgoCD token
- GitHub OAuth App values
- GitHub token

Backstage assumptions from the original lab were incomplete in practice:

- no Backstage image existed in ECR
- no Postgres secret schema was pre-known
- auth and guest login needed explicit config adjustments

Final working implementation:

- public GHCR Backstage image
- PostgreSQL subchart with corrected secret keys
- `techdocs` minimal config
- guest auth enabled for lab validation

Created and pushed to the GitOps repo:

- `catalog-info.yaml`

Validated:

- Backstage UI loads
- guest access works
- `bootcamp-api` appears in catalog UI

## 11. Practical Deviations From the Original Lab

The final implementation intentionally diverged from the idealized lab in these ways:

- Kyverno remained in `Audit`
- Backstage used public GHCR image
- Backstage was validated through internal access / `port-forward`
- GitOps source was a separate repo, not this workspace

These were not shortcuts in understanding.
They were the practical choices required to finish a working capstone in the actual environment.

## 12. Final Outcome

By the end of the run:

- the platform was rebuilt from zero
- `bootcamp-api` was running and instrumented
- ArgoCD was syncing from GitOps
- Kyverno was auditing guardrails
- policy-reporter was producing compliance data
- Backstage was up and showing the service in the catalog

## 13. Recommended Final Validation

Check:

```bash
kubectl get clusterpolicies -o custom-columns=NAME:.metadata.name,ACTION:.spec.validationFailureAction
kubectl get clusterpolicyreport | head
kubectl -n argocd get application bootcamp-api
kubectl -n bootcamp get rollout,svc,ingress,pods
kubectl -n backstage get pods
```

Capture UI evidence for:

- Backstage catalog page for `bootcamp-api`
- ArgoCD healthy application
- rollout / canary evidence
- Kyverno compliance reporting
