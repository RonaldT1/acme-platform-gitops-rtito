# Day 03 - Part 5: ALB + Security Groups + IAM

## Terraform validation

```bash
terraform fmt
terraform validate
terraform plan
terraform apply -auto-approve
```

## ECR import fix

```bash
terraform import aws_ecr_repository.app bootcamp-api
terraform plan
terraform apply -auto-approve
```

## Outputs

```bash
terraform output
```

## ALB verification

```bash
curl -I http://bootcamp-alb-1437740344.us-east-1.elb.amazonaws.com/
```

Expected result:

```http
HTTP/1.1 503 Service Temporarily Unavailable
```

Reason:

The ALB exists, but there is still no ECS service registered in the target group.

## IAM role verification

```bash
aws iam get-role --role-name bootcamp-ecs-execution-role --query 'Role.Arn' --output text

aws iam get-role --role-name bootcamp-ecs-task-role --query 'Role.Arn' --output text
```

## Docker / ECR image for ECS

```bash
ECR_URL=711387135481.dkr.ecr.us-east-1.amazonaws.com/bootcamp-api
AWS_REGION=us-east-1

aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_URL

docker build -f ../docker/Dockerfile -t $ECR_URL:day3 ..

docker push $ECR_URL:day3

aws ecr list-images --repository-name bootcamp-api --query 'imageIds[*].imageTag' --output table
```

## Result

- ALB created successfully.
- ALB DNS output available.
- Security Groups created successfully.
- ALB SG allows HTTP port 80 from the internet.
- ECS SG allows port 3000 only from the ALB Security Group.
- ECS Execution Role created successfully.
- ECS Task Role created successfully.
- ECR image available with immutable tag `day3`.
- Environment ready for ECS Fargate deployment (Part 6).
