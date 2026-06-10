# Day-21

## Day 1 - Repo Bootstrap, Terraform Backend, Multi-Env Scaffolding

## Verified Results

- The repository scaffold for `exercises/acme-platform` was created inside `day-21`.
  - Verified directories included `bootstrap`, `envs`, `modules`, `stacks`, `ci`, `helm`, `kustomize`, `docs`, `scripts`, and `provider-fortigate`.

- The Terraform bootstrap for the remote backend was organized into standard files.
  - `versions.tf`
  - `provider.tf`
  - `variables.tf`
  - `main.tf`
  - `outputs.tf`

- The backend resources were created successfully in AWS using the `rtito` naming convention.
  - S3 bucket: `rtito-tfstate-711387135481`
  - DynamoDB lock table: `rtito-tflock`

- Terraform apply completed successfully.
  - Result: `Apply complete! Resources: 5 added, 0 changed, 0 destroyed.`

- Terraform outputs confirmed the backend names.
  - `lock_table = "rtito-tflock"`
  - `state_bucket = "rtito-tfstate-711387135481"`

- AWS verification succeeded after apply.
  - `aws s3 ls | grep rtito-tfstate`
  - Result included: `rtito-tfstate-711387135481`
  - `aws dynamodb describe-table --table-name rtito-tflock --query 'Table.TableStatus'`
  - Result: `"ACTIVE"`

## What Happened During Testing

- `terraform validate` initially failed before `terraform init`, which was expected because the AWS provider had not yet been installed.
- `terraform plan` then failed with `ExpiredToken` even though AWS SSO login was active.
- The root cause was an old `bootcamp` profile entry in `~/.aws/credentials` that conflicted with the current SSO-based authentication flow.
- After removing the stale credentials entry, Terraform used the active SSO session correctly and the plan/apply succeeded.

## Files Prepared For Day 1

- `exercises/acme-platform/.terraform-version`
- `exercises/acme-platform/.gitignore`
- `exercises/acme-platform/.pre-commit-config.yaml`
- `exercises/acme-platform/README.md`
- `exercises/acme-platform/bootstrap/tf-backend/*.tf`
- `exercises/acme-platform/envs/sandbox/backend.hcl`

## Notes

- The backend bootstrap is the only Terraform configuration in this lab intended to run with local state.
- The backend bucket and DynamoDB table should be kept for later labs and should not be destroyed after this day if the following labs will use remote state.

## Summary

- The Day 1 scaffold was completed inside `day-21/exercises/acme-platform`.
- The remote Terraform backend was created successfully on AWS.
- The sandbox backend configuration now points to the real backend bucket and lock table.
