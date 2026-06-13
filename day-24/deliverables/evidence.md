# Day-24

## Day 4 - GKE Cluster + ArgoCD Bootstrap + Helm vs Kustomize

## Status

- Step 1 completed in code:
  - created `modules/gke-cluster` with separated `versions.tf`, `variables.tf`, `main.tf`, and `outputs.tf`
  - preserved `rtito` naming via `name = "rtito-${var.env}"` in the stack wiring
- Step 2 completed in code:
  - wired the new `gke` module into `stacks/gcp-platform`
  - added stack outputs for `cluster_name` and `cluster_endpoint`
- Steps 4, 5, and 6 completed in code:
  - added Helm chart under `helm/hello`
  - added Kustomize base and sandbox overlay under `kustomize/`
  - added ArgoCD `ApplicationSet` under `ci/argocd/applicationset.yaml`
- Local validation completed:
  - `terraform validate` passed for `stacks/gcp-platform`
  - `kubectl kustomize` rendered the sandbox overlay successfully
- Environment blockers for runtime execution:
  - `helm` is not installed in this environment
  - `gcloud` is not installed in this environment
  - `argocd` CLI is not installed in this environment
  - no GCP credentials are available here for a real `terraform apply`

## Captured Evidence

- Terraform validation result:
  - `Success! The configuration is valid.`
- Kustomize render verification:
  - rendered namespace: `rtito-hello-kustomize`
  - rendered deployment replicas: `1`
  - rendered env var: `ENV=sandbox`
- ApplicationSet alignment with real repo:
  - repo URL set to `https://github.com/amartinez-aquaware/bootcamp-2026-4.git`
  - Helm path set to `day-24/exercises/acme-platform/helm/hello`
  - Kustomize path set to `day-24/exercises/acme-platform/kustomize/overlays/sandbox`

## Notes

- The lab spec was adapted to the real repo layout instead of assuming a standalone `acme-platform.git` repository.
- The deprecated Kustomize `commonLabels` field was replaced with `labels`.
- Defaults in `modules/gke-cluster` were right-sized for the bootcamp run:
  - `node_count = 1`
  - `machine_type = "e2-medium"`
- Runtime steps still pending:
  - `terraform apply` for the GCP stack
  - `gcloud container clusters get-credentials`
  - ArgoCD installation and login
  - `kubectl apply -f ci/argocd/applicationset.yaml`
  - GitOps verification in-cluster
