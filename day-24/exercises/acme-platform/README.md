# acme-platform

Multi-env platform lab repository used inside `day-24/exercises/acme-platform`.

## Current Scope

- AWS legacy stack with reusable Terraform modules
- GCP platform stack with reusable VPC and GKE modules
- Private GKE cluster with Cloud NAT for node egress
- ArgoCD bootstrap plus GitOps examples for Helm and Kustomize

## Notes

- This project lives inside `day-24/exercises/acme-platform`; it is not a standalone Git repository.
- Terraform resource naming follows the `rtito` prefix convention.
- The AWS backend bootstrap remains separate under `bootstrap/tf-backend`.
- For the GCP stack, the GCS backend bucket is created manually for this bootcamp flow because it is only a single bootstrap resource.
- If the GCP backend grows beyond a small number of resources, move it into a dedicated Terraform bootstrap stack.

## Layout

- `bootstrap/tf-backend`: creates the AWS S3 bucket and DynamoDB table for the legacy remote state flow
- `ci/argocd`: GitOps manifests, including the `ApplicationSet`
- `envs/`: per-environment backend and tfvars files
- `helm/hello`: reference Helm app for the lab
- `kustomize/`: base and overlays for the reference Kustomize app
- `modules/`: reusable Terraform modules such as `aws-vpc`, `aws-rds`, `gcp-vpc`, and `gke-cluster`
- `stacks/`: composed Terraform stacks such as `aws-legacy` and `gcp-platform`
- `scripts/`, `docs/`, `provider-fortigate/`: supporting project structure

## GCP Platform Notes

- `stacks/gcp-platform` uses a `gcs` backend.
- The inherited `envs/sandbox/backend.hcl` file is for the AWS `s3` backend and does not apply to the GCP stack.
- The private GKE cluster depends on Cloud NAT so nodes can pull images from external registries without public IPs.

## GitOps Notes

- ArgoCD syncs the lab apps from Git, not from the local filesystem.
- For this run, the GitOps source was published to:
  - `https://github.com/RonaldT1/acme-platform-gitops-rtito.git`
- The reference apps are deployed in two ways:
  - Helm: `day-24/exercises/acme-platform/helm/hello`
  - Kustomize: `day-24/exercises/acme-platform/kustomize/overlays/sandbox`
