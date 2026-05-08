# Day 04 - Commands

## Terraform

### Init

```bash
cd exercises/aws-bootcamp/infra
terraform init
```

### Plan

```bash
terraform plan
```

### Apply

```bash
terraform apply
```

### Outputs

```bash
terraform output
terraform output alb_dns_name
terraform output cloudfront_domain_name
terraform output cloudfront_distribution_id
terraform output frontend_bucket_name
```

### Imports

```bash
terraform import aws_cloudfront_distribution.frontend <distribution-id>
terraform import aws_s3_bucket.frontend <bucket-name>
terraform import aws_ecs_service.api <cluster-name>/<service-name>
```

## Docker / ECR

### Build

```bash
cd exercises/aws-bootcamp/app
docker build -t bootcamp-api .
```

### Tag

```bash
docker tag bootcamp-api:latest <aws-account-id>.dkr.ecr.<region>.amazonaws.com/bootcamp-api:latest
docker tag bootcamp-api:latest <aws-account-id>.dkr.ecr.<region>.amazonaws.com/bootcamp-api:day04
```

### Login

```bash
aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <aws-account-id>.dkr.ecr.<region>.amazonaws.com
```

### Push

```bash
docker push <aws-account-id>.dkr.ecr.<region>.amazonaws.com/bootcamp-api:latest
docker push <aws-account-id>.dkr.ecr.<region>.amazonaws.com/bootcamp-api:day04
```

## GitHub Actions

### Git Add

```bash
git add .github/workflows/deploy-backend.yml
git add .github/workflows/deploy-frontend.yml
git add infra
git add frontend
git add app
```

### Commit

```bash
git commit -m "Add backend and frontend CI/CD workflows"
```

### Push

```bash
git push origin main
```

## AWS CLI Validation

### ECS

```bash
aws ecs describe-services \
  --cluster bootcamp-cluster \
  --services bootcamp-api-service
```

```bash
aws ecs describe-services \
  --cluster bootcamp-cluster \
  --services bootcamp-api-service \
  --query "services[0].deployments"
```

```bash
aws ecs describe-services \
  --cluster bootcamp-cluster \
  --services bootcamp-api-service \
  --query "services[0].runningCount"
```

### S3

```bash
aws s3 ls
aws s3 ls s3://<frontend-bucket-name>
aws s3 ls s3://<frontend-bucket-name> --recursive
```

```bash
aws s3 sync frontend/dist s3://<frontend-bucket-name> --delete
```

### CloudFront

```bash
aws cloudfront list-distributions
```

```bash
aws cloudfront get-distribution \
  --id <cloudfront-distribution-id>
```

```bash
aws cloudfront create-invalidation \
  --distribution-id <cloudfront-distribution-id> \
  --paths "/*"
```

```bash
aws cloudfront get-invalidation \
  --distribution-id <cloudfront-distribution-id> \
  --id <invalidation-id>
```

## Curl Validation

### Backend

```bash
curl http://<alb-dns-name>/health
curl http://<alb-dns-name>/api/hello
```

### Frontend

```bash
curl https://<cloudfront-domain-name>
```

### Headers

```bash
curl -I https://<cloudfront-domain-name>
curl -I http://<alb-dns-name>/health
```

Expected frontend result:

```text
HTTP/2 200
```

## Troubleshooting Commands

### Terraform Output Debugging

```bash
cd exercises/aws-bootcamp/infra
terraform output
terraform output -raw cloudfront_domain_name
terraform output -raw cloudfront_distribution_id
terraform output -raw frontend_bucket_name
terraform state list
terraform state show aws_cloudfront_distribution.frontend
terraform state show aws_s3_bucket_policy.frontend
```

### S3 Debugging

```bash
aws s3 ls s3://<frontend-bucket-name>
aws s3 ls s3://<frontend-bucket-name> --recursive
aws s3api get-bucket-policy --bucket <frontend-bucket-name>
aws s3api get-public-access-block --bucket <frontend-bucket-name>
```

### CloudFront Invalidation Debugging

```bash
aws cloudfront create-invalidation \
  --distribution-id <cloudfront-distribution-id> \
  --paths "/*"
```

```bash
aws cloudfront list-invalidations \
  --distribution-id <cloudfront-distribution-id>
```

```bash
aws cloudfront get-distribution-config \
  --id <cloudfront-distribution-id>
```

### ECS Service Debugging

```bash
aws ecs describe-services \
  --cluster bootcamp-cluster \
  --services bootcamp-api-service \
  --query "services[0].events[0:10]"
```

```bash
aws ecs list-tasks \
  --cluster bootcamp-cluster \
  --service-name bootcamp-api-service
```

```bash
aws ecs describe-tasks \
  --cluster bootcamp-cluster \
  --tasks <task-arn>
```

### Failed Curl Checks

```bash
curl -v https://<cloudfront-domain-name>
curl -v http://<alb-dns-name>/health
curl -I https://<cloudfront-domain-name>
curl -I https://<cloudfront-domain-name>/index.html
```

### URL Variable Debugging

```bash
CF_DOMAIN=$(terraform output -raw cloudfront_domain_name)
echo "$CF_DOMAIN"
curl -I "https://$CF_DOMAIN"
```

```bash
CF_DIST_ID=$(terraform output -raw cloudfront_distribution_id)
echo "$CF_DIST_ID"
aws cloudfront get-distribution --id "$CF_DIST_ID"
```

### Frontend Build Path Debugging

```bash
cd exercises/aws-bootcamp/frontend
npm install
npm run build
ls
ls dist
```

```bash
aws s3 sync dist s3://<frontend-bucket-name> --delete
```
