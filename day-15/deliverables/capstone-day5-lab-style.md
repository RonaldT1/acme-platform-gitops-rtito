# Day 15 — Capstone Lab Style Walkthrough

## Context

Before starting Part 5 itself, the base platform had to be rebuilt after `terraform destroy`.

That prerequisite recovery included:

- EKS
- ALB Controller
- Karpenter
- Argo Rollouts
- kube-prometheus-stack
- OpenTelemetry stack
- `bootcamp-api`
- ArgoCD

The steps below focus only on the capstone work from Kyverno onward.

## Step 1. Install Kyverno

Here we installed the policy engine and prepared its runtime configuration.

Worked files:

- [kyverno-values.yaml](/home/ronald/projects/bootcamp-2026-4/day-15/exercises/aws-bootcamp/infra/kyverno-values.yaml)

What this step does:

- deploys Kyverno controllers
- configures admission behavior
- enables metrics integration with monitoring

Important note:

- Kyverno was kept in `Audit` mode during the lab
- `Audit` reports violations without blocking deployments

## Step 2. Install policy-reporter

Here we installed the reporting layer for Kyverno results.

What this step does:

- collects policy findings
- provides an easier way to inspect violations

Why it mattered:

- the capstone is not only about writing policies
- it is also about showing compliance visibility

## Step 3. Create the five Kyverno policies

Here we added the five organizational guardrails required by the capstone.

Worked files:

- [01-disallow-latest-tag.yaml](/home/ronald/projects/bootcamp-2026-4/day-15/exercises/aws-bootcamp/k8s/kyverno/01-disallow-latest-tag.yaml)
- [02-require-requests-limits.yaml](/home/ronald/projects/bootcamp-2026-4/day-15/exercises/aws-bootcamp/k8s/kyverno/02-require-requests-limits.yaml)
- [03-only-org-ecr.yaml](/home/ronald/projects/bootcamp-2026-4/day-15/exercises/aws-bootcamp/k8s/kyverno/03-only-org-ecr.yaml)
- [04-disallow-privileged.yaml](/home/ronald/projects/bootcamp-2026-4/day-15/exercises/aws-bootcamp/k8s/kyverno/04-disallow-privileged.yaml)
- [05-namespace-owner-label.yaml](/home/ronald/projects/bootcamp-2026-4/day-15/exercises/aws-bootcamp/k8s/kyverno/05-namespace-owner-label.yaml)

What this step does:

- checks image tags
- checks resource requests and limits
- checks registry origin
- checks privileged mode
- checks namespace ownership labeling

## Step 4. Tune policy behavior for the real cluster

Here we reduced policy noise so the reports were meaningful in the rebuilt environment.

What we adjusted:

- excluded `karpenter` from requests/limits checks
- excluded system namespaces from the namespace-owner rule
- labeled owned namespaces with `owner=team-platform`

Why it mattered:

- a raw `Audit` rollout on a live platform produces noise
- this step made the reports useful instead of noisy

## Step 5. Review policy results

Here we validated that Kyverno was active and producing reports.

What we looked for:

- all five `ClusterPolicy` objects ready
- cluster-wide reports present
- `bootcamp-api` compliant
- expected `Audit` findings on platform components

This confirmed that policy visibility was working.

## Step 6. Prepare Backstage RBAC

Here we created the Kubernetes access layer for Backstage.

Worked files:

- [rbac.yaml](/home/ronald/projects/bootcamp-2026-4/day-15/exercises/aws-bootcamp/k8s/backstage/rbac.yaml)

What this step does:

- creates a `backstage` service account
- grants cluster read access
- creates a token secret for the Kubernetes plugin

Why it mattered:

- Backstage needs read access to Kubernetes objects
- otherwise the Kubernetes plugin cannot show workloads

## Step 7. Prepare Backstage configuration

Here we created the main Backstage values file.

Worked files:

- [backstage-values.yaml](/home/ronald/projects/bootcamp-2026-4/day-15/exercises/aws-bootcamp/infra/backstage-values.yaml)

What this step configures:

- app URLs
- database
- GitHub auth
- catalog location
- Kubernetes integration
- ArgoCD integration
- ingress

Important practical changes:

- switched to a public Backstage image because no Backstage image existed in ECR
- added minimal `techdocs` config
- enabled guest auth for lab validation

## Step 8. Prepare catalog metadata

Here we prepared the metadata that lets Backstage discover `bootcamp-api`.

Worked files:

- [catalog-info.yaml](/home/ronald/projects/bootcamp-2026-4/day-15/exercises/aws-bootcamp/catalog-info.yaml)

What this step does:

- defines `bootcamp-api` as a Backstage `Component`
- links it to Kubernetes
- links it to ArgoCD
- assigns owner and system metadata

Important design choice:

- the final `catalog-info.yaml` was placed in the GitOps repo
- that repo is the real source of truth that Backstage and ArgoCD refer to

## Step 9. Collect Backstage secrets and access values

Here we gathered the values Backstage needed to start correctly.

What was collected:

- Kubernetes service account token
- Kubernetes CA data
- ArgoCD token
- GitHub OAuth client ID and secret
- GitHub token
- PostgreSQL password

Why it mattered:

- Backstage depends on several external integrations
- the chart alone is not enough without these values

## Step 10. Install Backstage

Here we deployed Backstage and PostgreSQL.

What had to be corrected during this step:

- PostgreSQL secret key names
- truncated Kubernetes token values
- missing `techdocs` config
- guest auth behavior outside strict development mode

Once corrected, the deployment became healthy.

## Step 11. Validate the portal

Here we confirmed that the portal was actually usable.

What we validated:

- Backstage UI loaded
- guest login worked
- `bootcamp-api` appeared in the catalog

This was the main capstone outcome for the portal side.

## Step 12. Capture final evidence

Here we collected the final outputs and screenshots.

What we captured:

- Kyverno policy list
- compliance report output
- Backstage pod status
- ArgoCD application status
- `bootcamp-api` rollout, service, ingress, and pods
- UI screenshots

## Final Outcome

By the end of these steps:

- Kyverno was installed and auditing
- policy-reporter was working
- Backstage was running
- `bootcamp-api` was visible in Backstage
- ArgoCD was syncing the application from the GitOps repo

That completed the practical implementation of the capstone.
