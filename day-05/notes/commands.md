# Day 05: Commands

This document summarizes the primary commands used during the Day 05 implementation, including Terraform provisioning, ECS deployments, CI/CD automation, monitoring, autoscaling, rollback validation, and smoke testing.

---

## Terraform

```bash
cd exercises/aws-bootcamp/infra
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
terraform output
terraform state list
```

## Docker / ECR

```bash
docker build -t bootcamp-api .
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <ecr-url>
docker push <ecr-url>:day05
```

## Frontend

```bash
npm install
npm run dev
npm run build
```

## GitHub Actions

```bash
git add .
git commit -m "Add monitoring, autoscaling, rollback, and smoke tests"
git push origin rtito-aquaware
```

## Smoke Tests

```bash
chmod +x scripts/smoke-test.sh
./scripts/smoke-test.sh
```

## CloudWatch / SNS

```bash
aws cloudwatch describe-alarms
aws sns list-topics
aws sns list-subscriptions
```

## ECS Validation

```bash
aws ecs describe-services --cluster bootcamp-cluster --services bootcamp-api-service
aws ecs list-tasks --cluster bootcamp-cluster --service-name bootcamp-api-service
```

## Autoscaling

```bash
aws application-autoscaling describe-scaling-policies --service-namespace ecs --resource-id "service/bootcamp-cluster/bootcamp-api-service"
```

## SSM Parameter Store

```bash
aws ssm put-parameter --name "/bootcamp/APP_ENV" --value "production" --type String
aws ssm get-parameter --name "/bootcamp/APP_ENV"
```

## Rollback Validation

```bash
# Replace /bootcamp/APP_ENV with /bootcamp/INVALID_PARAM
git commit -m "test: trigger backend rollback"
git push origin rtito-aquaware
```

## Full Teardown

```bash
aws s3 rm s3://$BUCKET --recursive
terraform destroy -var="alert_email=you@example.com" -auto-approve
```
