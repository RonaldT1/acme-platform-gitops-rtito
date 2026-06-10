# Day-21

## Day 1 - Repo Bootstrap, Terraform Backend, Multi-Env Scaffolding

## Repository Skeleton

```bash
cd ~/projects/bootcamp-2026-4/day-21/exercises/acme-platform
ls
cd bootstrap
ls
cd tf-backend
ls
```

## Terraform Bootstrap Validation

```bash
terraform fmt
terraform validate
```

## AWS Session Diagnostics

```bash
echo "$AWS_PROFILE"
env | grep '^AWS_'
aws configure list
aws sso login
aws sts get-caller-identity
```

## Terraform Backend Bootstrap

```bash
terraform init
terraform validate
terraform plan
terraform apply -auto-approve
terraform output
```

## Backend Verification

```bash
aws s3 ls | grep rtito-tfstate
aws dynamodb describe-table --table-name rtito-tflock --query 'Table.TableStatus'
```

## Important Follow-Up

```bash
# The old bootcamp profile block in ~/.aws/credentials had to be removed
# because it conflicted with the active SSO-based session used by Terraform.
```
