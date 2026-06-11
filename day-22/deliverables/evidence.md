# Day-22

## Verified Results

- GCP state bucket `gs://rtito-tfstate-bootcamp-aquaware` was created in `us-central1` with uniform bucket-level access and versioning enabled.
- `terraform init` completed successfully for `stacks/gcp-platform` after configuring Application Default Credentials for GCP.
- `terraform apply -var-file=../../envs/sandbox/gcp-platform.tfvars -auto-approve` created:
  - VPC network `rtito-sandbox`
  - subnet `nodes`
  - subnet `services`
- Terraform output returned:
  - `network_id = "projects/bootcamp-aquaware/global/networks/rtito-sandbox"`
- GCP verification confirmed:
  - network `rtito-sandbox`
  - subnets `nodes` and `services`
- AWS backend bootstrap was recreated successfully after the previous lab cleanup removed the S3/DynamoDB state resources.
- `bootstrap/tf-backend` outputs confirmed:
  - `state_bucket = "rtito-tfstate-711387135481"`
  - `lock_table = "rtito-tflock"`
- `terraform init` and `terraform apply -var-file=../../envs/sandbox/aws-legacy.tfvars -auto-approve` completed successfully for `stacks/aws-legacy`.
- AWS resources created:
  - VPC `vpc-0b1a2fd90464fb31f`
  - Internet Gateway `igw-067286feaf973d6d2`
  - public subnet `subnet-0b24f58b8a6da5a1a` in `us-east-1a`
  - public subnet `subnet-09e5df5371f955af1` in `us-east-1b`
  - private subnet `subnet-022c254fd7583e6a0` in `us-east-1a`
  - private subnet `subnet-069fe670011428ac4` in `us-east-1b`
- Terraform output returned:
  - `vpc_id = "vpc-0b1a2fd90464fb31f"`
- GCP and AWS verification commands were executed successfully after deployment.
- During cleanup, the AWS state bucket required manual deletion of object versions and delete markers because versioning was enabled.
- The bootstrap backend bucket configuration was updated to `force_destroy = true` to make future lab cleanup easier.
- Terraform module and stack scaffolding for the Day 2 lab was added under `exercises/acme-platform`.
- `terraform fmt -recursive` completed successfully after file creation.
- Terraform files were refactored into `versions.tf`, `variables.tf`, `main.tf`, `outputs.tf`, and `provider.tf` where appropriate to keep modules reusable and roots clearer.
- Environment-specific `tfvars` files were added for `sandbox` so `env=sandbox` does not depend on CLI memory.
- The GCP sandbox tfvars file was updated with `project_id = "bootcamp-aquaware"`.

## Notes

- Add only evidence produced during Day 22 work.
- Lab Day 2 focused on reusable Terraform modules for AWS and GCP with matching interface shape.
- Resource naming was adapted from `acme-*` in the prompt to `rtito-*` to follow the repo convention.
- Existing AWS backend bootstrap and `envs/sandbox/backend.hcl` were preserved.
