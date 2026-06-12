# Day-23 Commands

## Repository Inspection

```bash
cd ~/projects/bootcamp-2026-4/day-23
rg --files exercises/acme-platform
sed -n '1,220p' exercises/acme-platform/stacks/aws-legacy/main.tf
sed -n '1,220p' exercises/acme-platform/stacks/aws-legacy/variables.tf
sed -n '1,220p' exercises/acme-platform/envs/sandbox/aws-legacy.tfvars
sed -n '1,220p' exercises/acme-platform/envs/sandbox/backend.hcl
```

## Backend Recreation

```bash
cd ~/projects/bootcamp-2026-4/day-23/exercises/acme-platform/bootstrap/tf-backend
terraform init
terraform apply -auto-approve
```

Observed output:

```text
Apply complete! Resources: 5 added, 0 changed, 0 destroyed.

Outputs:
lock_table = "rtito-tflock"
state_bucket = "rtito-tfstate-711387135481"
```

## Manual Legacy Resource Creation

```bash
aws ec2 run-instances --image-id "$(aws ec2 describe-images \
  --owners amazon --filters "Name=name,Values=al2023-ami-*-x86_64" \
  --query 'sort_by(Images,&CreationDate)[-1].ImageId' --output text)" \
  --instance-type t3.micro \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=rtito-legacy-app-01},{Key=Env,Value=sandbox}]' \
  --count 1

aws rds create-db-instance \
  --db-instance-identifier rtito-legacy-db \
  --db-instance-class db.t3.micro \
  --engine postgres --engine-version 16.3 \
  --master-username acme --master-user-password ChangeMe123! \
  --allocated-storage 20 --no-publicly-accessible --storage-encrypted \
  --tags Key=Env,Value=sandbox Key=ManagedBy,Value=manual-will-import

aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=rtito-legacy-app-01" "Name=instance-state-name,Values=pending,running,stopped,stopping" \
  --query 'Reservations[].Instances[].InstanceId' --output text

aws rds describe-db-instances \
  --db-instance-identifier rtito-legacy-db \
  --query 'DBInstances[0].[DBInstanceIdentifier,DBInstanceStatus,Engine,EngineVersion]' \
  --output table
```

Observed output:

```text
i-06785968dcf91c9a8

---------------------
|DescribeDBInstances|
+-------------------+
|  rtito-legacy-db  |
|  available        |
|  postgres         |
|  16.3             |
+-------------------+
```

## Import Workflow

```bash
cd ~/projects/bootcamp-2026-4/day-23/exercises/acme-platform/stacks/aws-legacy
terraform init -backend-config=../../envs/sandbox/backend.hcl -reconfigure

terraform plan -generate-config-out=generated.tf \
  -var-file=../../envs/sandbox/aws-legacy.tfvars \
  -var 'db_password=ChangeMe123!'

terraform apply \
  -var-file=../../envs/sandbox/aws-legacy.tfvars \
  -var 'db_password=ChangeMe123!'
```

Issues encountered before config generation:

```text
Error: Target generated file already exists
```

Resolution:

```bash
rm generated.tf
```

```text
Error: Reference to undeclared resource
  on outputs.tf line 2, in output "legacy_app_id":
  value = aws_instance.legacy_app.id
```

Resolution:

```text
Move the EC2 placeholder resource out of generated.tf into legacy_app.tf.
```

```text
Error: Missing required argument
  with aws_instance.legacy_app
  "instance_type": one of instance_type,launch_template must be specified
  "ami": one of ami,launch_template must be specified
```

Resolution command:

```bash
aws ec2 describe-instances \
  --instance-ids i-06785968dcf91c9a8 \
  --query 'Reservations[0].Instances[0].[ImageId,InstanceType]' \
  --output table
```

Observed output:

```text
---------------------------
|    DescribeInstances    |
+-------------------------+
|  ami-03120525e2a3df46f  |
|  t3.micro               |
+-------------------------+
```

Current generated-config plan result:

```text
Plan: 2 to import, 0 to add, 2 to change, 0 to destroy.

Changes to Outputs:
  + legacy_app_id         = "i-06785968dcf91c9a8"
  + legacy_app_private_ip = "172.31.20.90"
  + rds_arn               = "arn:aws:rds:us-east-1:711387135481:db:rtito-legacy-db"
  + rds_endpoint          = "rtito-legacy-db.con0qiowui9u.us-east-1.rds.amazonaws.com:5432"
```

Alignment changes made in code before re-planning:

```text
- Move EC2 placeholder into legacy_app.tf
- Set EC2 ami and instance_type to match the real instance
- Add EC2 tags to match the real instance
- Parameterize RDS deletion_protection and skip_final_snapshot
- Set RDS defaults to match the manually created DB
```

Clean import plan result:

```text
Plan: 2 to import, 0 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + legacy_app_id         = "i-06785968dcf91c9a8"
  + legacy_app_private_ip = "172.31.20.90"
  + rds_arn               = "arn:aws:rds:us-east-1:711387135481:db:rtito-legacy-db"
  + rds_endpoint          = "rtito-legacy-db.con0qiowui9u.us-east-1.rds.amazonaws.com:5432"
```

Important note from this run:

```text
Terraform did not create generated.tf. Once the code was explicit enough,
Terraform could plan the imports directly and no extra generated resource file
was needed for this specific import path.
```

## Import Apply

```bash
terraform force-unlock d715c5bd-a935-d444-3afe-cb9281292feb

terraform apply \
  -var-file=../../envs/sandbox/aws-legacy.tfvars \
  -var 'db_password=ChangeMe123!' \
  -auto-approve

terraform state list | grep -E '(rds|legacy_app)'
```

Observed output:

```text
Apply complete! Resources: 2 imported, 0 added, 0 changed, 0 destroyed.

Outputs:
legacy_app_id = "i-06785968dcf91c9a8"
legacy_app_private_ip = "172.31.20.90"
rds_arn = "arn:aws:rds:us-east-1:711387135481:db:rtito-legacy-db"
rds_endpoint = "rtito-legacy-db.con0qiowui9u.us-east-1.rds.amazonaws.com:5432"

aws_instance.legacy_app
module.rds.aws_db_instance.this
```

## Verification

```bash
terraform state list | grep -E '(rds|legacy_app)'
terraform plan \
  -var-file=../../envs/sandbox/aws-legacy.tfvars \
  -var 'db_password=ChangeMe123!' \
  | grep -E 'No changes|0 to add, 0 to change, 0 to destroy'
```

## Drift Detection

```bash
cd ~/projects/bootcamp-2026-4/day-23/exercises/acme-platform
chmod +x scripts/detect-drift.sh
DB_PASSWORD=ChangeMe123! ./scripts/detect-drift.sh
```

## Cleanup

```bash
sed -i 's/prevent_destroy = true/prevent_destroy = false/' modules/aws-rds/main.tf
aws rds modify-db-instance --db-instance-identifier rtito-legacy-db \
  --no-deletion-protection --apply-immediately

cd ~/projects/bootcamp-2026-4/day-23/exercises/acme-platform/stacks/aws-legacy
terraform destroy \
  -var-file=../../envs/sandbox/aws-legacy.tfvars \
  -var 'db_password=ChangeMe123!' \
  -auto-approve
```
