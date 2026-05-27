# Day 15 — High-Level Steps

## 1. Reset the repo to a real Day 15 baseline

The repo started as a Day 14 copy, so we first cleaned leftovers, removed local artifacts, and updated names that still pointed to `day-14`.

## 2. Recreate the infrastructure

After `terraform destroy`, we rebuilt the AWS base with Terraform:

- VPC
- subnets
- EKS
- node group
- ECR
- IAM / OIDC
- storage support

This restored the cluster foundation required by the capstone.

## 3. Reinstall the platform prerequisites

We reinstalled the components the capstone assumes already exist:

- AWS Load Balancer Controller
- Karpenter
- Argo Rollouts
- kube-prometheus-stack

These provide ingress, autoscaling, rollout control, and monitoring.

## 4. Rebuild observability

We restored the telemetry stack:

- OpenTelemetry Operator
- Tempo
- Loki
- OTel collectors

This re-enabled traces, logs, metrics, and auto-instrumentation.

## 5. Rebuild and validate the application

We rebuilt `bootcamp-api`, pushed a fresh image to ECR, redeployed it, and verified:

- healthy pods
- ALB ingress
- `/health`
- `/api/hello`
- `/api/slow`
- OpenTelemetry injection

## 6. Reconnect GitOps with ArgoCD

We reinstalled ArgoCD and pointed it to the separate GitOps repo:

- `RonaldT1/ronald-bootcamp-gitops`

This repo remained the lab workspace, while the GitOps repo became the deployment source of truth.

## 7. Add Kyverno policies

We installed:

- Kyverno
- policy-reporter

Then we applied the five capstone policies in `Audit` mode.

`Audit` reports violations without blocking resources.
`Enforce` would reject non-compliant resources.

## 8. Reduce policy noise

We tuned the policy set to make reports useful:

- excluded system namespaces from namespace-owner checks
- excluded `karpenter` from requests/limits checks
- labeled owned namespaces with `owner=team-platform`

## 9. Prepare Backstage metadata and access

We added:

- Backstage RBAC
- service account access to the cluster
- `catalog-info.yaml` for `bootcamp-api`

The catalog metadata was placed in the GitOps repo so Backstage could discover it from GitHub.

## 10. Install Backstage

Backstage required several practical fixes:

- PostgreSQL secret format
- Kubernetes token and CA setup
- ArgoCD token creation
- GitHub auth setup
- missing `techdocs` config
- guest auth enablement

We used a public Backstage image to avoid building a separate image pipeline just for the lab.

## 11. Validate the portal

We confirmed that:

- Backstage started correctly
- guest login worked
- `bootcamp-api` appeared in the catalog

At that point, the service was visible in Backstage, synced by ArgoCD, and covered by Kyverno reporting.

## 12. Capture evidence

Finally, we collected:

- UI screenshots
- cluster verification output
- ArgoCD status
- Backstage status
- Kyverno reports

The final documentation reflects the real path required to make the lab work in practice.
