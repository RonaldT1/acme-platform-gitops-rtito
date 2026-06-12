# Day-23

## Day 3 - Importing Legacy Infrastructure (RDS + EC2) into Terraform

## Status

- Repo prepared for the import workflow in `exercises/acme-platform`.
- AWS backend was recreated successfully for day-23.
- Legacy AWS resources were recreated manually:
  - EC2 `rtito-legacy-app-01`
  - RDS `rtito-legacy-db`
- The first generated-config plan completed and reached the import stage.
- The import plan is now clean and safe to apply:
  - `Plan: 2 to import, 0 to add, 0 to change, 0 to destroy.`
- Terraform import apply completed successfully.
- Evidence below must be completed only with outputs produced during day-23 execution.

## Captured Evidence

- AWS backend bootstrap recreation:
  - `state_bucket = "rtito-tfstate-711387135481"`
  - `lock_table = "rtito-tflock"`
- Manual legacy resources:
  - EC2 instance ID for `rtito-legacy-app-01`: `i-06785968dcf91c9a8`
  - RDS identifier `rtito-legacy-db`
  - RDS engine `postgres 16.3`
  - RDS status reached `available`
- Terraform import verification:
  - initial import plan summary:
    - `Plan: 2 to import, 0 to add, 2 to change, 0 to destroy.`
  - clean import plan summary:
    - `Plan: 2 to import, 0 to add, 0 to change, 0 to destroy.`
  - import apply summary:
    - `Apply complete! Resources: 2 imported, 0 added, 0 changed, 0 destroyed.`
  - output preview from the clean plan:
    - `legacy_app_id = "i-06785968dcf91c9a8"`
    - `legacy_app_private_ip = "172.31.20.90"`
    - `rds_arn = "arn:aws:rds:us-east-1:711387135481:db:rtito-legacy-db"`
    - `rds_endpoint = "rtito-legacy-db.con0qiowui9u.us-east-1.rds.amazonaws.com:5432"`
  - imported addresses verified in state:
    - `aws_instance.legacy_app`
    - `module.rds.aws_db_instance.this`
- Drift detection verification:
  - pending until import completes

## Notes

- Do not copy screenshots, outputs, or resource IDs from day-22.
- Use `rtito` naming for recreated resources and captured evidence.
- Two scaffold issues appeared before generation succeeded:
  - `generated.tf` could not be pre-created because `-generate-config-out` only writes to a new file.
  - `aws_instance.legacy_app` could not be empty because the provider validates required arguments before generating config.
- In this run, Terraform never wrote `generated.tf` because the final configuration was already explicit enough for Terraform to plan the imports directly from code.
- One `terraform apply` attempt failed because a stale DynamoDB state lock was left behind and had to be released with `terraform force-unlock`.
