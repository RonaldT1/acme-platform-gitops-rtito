# Day-22

## Day 2 - Reusable Terraform Modules (AWS VPC + GCP VPC)

## Repository Inspection

```bash
cd ~/projects/bootcamp-2026-4/day-22
rg --files exercises/acme-platform
find . -maxdepth 2 \( -name AGENTS.md -o -name README.md \)
git status --short

cd exercises/acme-platform
sed -n '1,220p' README.md
sed -n '1,220p' envs/sandbox/backend.hcl
sed -n '1,220p' bootstrap/tf-backend/main.tf
sed -n '1,220p' bootstrap/tf-backend/variables.tf
sed -n '1,220p' bootstrap/tf-backend/provider.tf
sed -n '1,220p' bootstrap/tf-backend/outputs.tf
sed -n '1,220p' bootstrap/tf-backend/versions.tf
find . -maxdepth 3 -type d | sort
find modules/aws-vpc -maxdepth 2 -type f | sort
find modules/gcp-vpc -maxdepth 2 -type f | sort
find stacks/aws-legacy -maxdepth 2 -type f | sort
find stacks/gcp-platform -maxdepth 2 -type f | sort
find modules stacks -maxdepth 2 -type f | sort
find envs -maxdepth 2 -type f | sort
find stacks -maxdepth 2 -type f | sort
```

## Terraform Formatting

```bash
cd ~/projects/bootcamp-2026-4/day-22/exercises/acme-platform
terraform fmt -recursive
terraform fmt -recursive
```

## GCP Project And Backend Preparation

```bash
gcloud config get-value project
gcloud storage buckets create gs://rtito-tfstate-$(gcloud config get-value project) \
  --location=us-central1 \
  --uniform-bucket-level-access
gcloud storage buckets update gs://rtito-tfstate-$(gcloud config get-value project) \
  --versioning
gcloud storage buckets describe gs://rtito-tfstate-$(gcloud config get-value project)
```

## GCP Authentication

```bash
gcloud auth application-default login
gcloud auth application-default set-quota-project bootcamp-aquaware
```

## GCP Stack Deploy

```bash
cd ~/projects/bootcamp-2026-4/day-22/exercises/acme-platform/stacks/gcp-platform
terraform init \
  -backend-config="bucket=rtito-tfstate-$(gcloud config get-value project)" \
  -backend-config="prefix=sandbox"
terraform apply \
  -var-file=../../envs/sandbox/gcp-platform.tfvars \
  -auto-approve
```

## GCP Verification

```bash
gcloud compute networks list --filter="name:rtito-sandbox"
gcloud compute networks subnets list --filter="network:rtito-sandbox"
```

## AWS Session Diagnostics

```bash
aws sts get-caller-identity
```

## AWS Backend Bootstrap

```bash
cd ~/projects/bootcamp-2026-4/day-22/exercises/acme-platform/bootstrap/tf-backend
terraform init
terraform apply -auto-approve
```

## AWS Stack Deploy

```bash
cd ~/projects/bootcamp-2026-4/day-22/exercises/acme-platform/stacks/aws-legacy
terraform init -backend-config=../../envs/sandbox/backend.hcl
terraform apply -var-file=../../envs/sandbox/aws-legacy.tfvars -auto-approve
```

## Cleanup

```bash
cd ~/projects/bootcamp-2026-4/day-22/exercises/acme-platform/stacks/aws-legacy
terraform destroy -var-file=../../envs/sandbox/aws-legacy.tfvars -auto-approve

cd ~/projects/bootcamp-2026-4/day-22/exercises/acme-platform/stacks/gcp-platform
terraform destroy -var-file=../../envs/sandbox/gcp-platform.tfvars -auto-approve

gcloud storage rm --recursive gs://rtito-tfstate-$(gcloud config get-value project)

cd ~/projects/bootcamp-2026-4/day-22/exercises/acme-platform/bootstrap/tf-backend
terraform destroy -auto-approve
```

## AWS Backend Manual Cleanup

```bash
aws s3api list-object-versions --bucket rtito-tfstate-711387135481
aws s3 rm s3://rtito-tfstate-711387135481 --recursive
aws s3 rb s3://rtito-tfstate-711387135481 --force
aws s3api delete-object --bucket rtito-tfstate-711387135481 --key sandbox/terraform.tfstate --version-id WPAFpfyUAUsac4Thr0TGuL4ZmNiVlAR8
aws s3api delete-object --bucket rtito-tfstate-711387135481 --key sandbox/terraform.tfstate --version-id 0f01MKsxR9RtycLA3JflvXp8GLG_b9n9
aws s3api delete-object --bucket rtito-tfstate-711387135481 --key sandbox/terraform.tfstate --version-id null
aws s3api list-object-versions --bucket rtito-tfstate-711387135481
aws s3 rb s3://rtito-tfstate-711387135481
cd ~/projects/bootcamp-2026-4/day-22/exercises/acme-platform/bootstrap/tf-backend
terraform destroy -auto-approve
```

## Important Follow-Up

```bash
# The AWS backend bucket used versioning, so deleting the current object
# was not enough. Old object versions and the delete marker had to be removed
# before the S3 bucket itself could be deleted.
```
