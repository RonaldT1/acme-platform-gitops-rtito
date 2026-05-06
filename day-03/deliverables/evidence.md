# Day 03 - Evidence (ECS Fargate + ALB)

## Infrastructure Provisioned

### Application Load Balancer

- Public ALB created
- Listener on port 80
- Target Group configured
- Health check endpoint:
  - `/health`

### Security Groups

#### ALB Security Group

Allows:

- HTTP 80 from `0.0.0.0/0`

#### ECS Security Group

Allows:

- Port 3000 only from ALB Security Group

---

## IAM Roles

### ECS Execution Role

Used by ECS to:

- Pull images from ECR
- Send logs to CloudWatch

### ECS Task Role

Used by containers to:

- Access AWS services
- Read SSM parameters

---

## ECS Infrastructure

### ECS Cluster

Cluster name:

- `bootcamp-cluster`

### ECS Service

Launch type:

- `FARGATE`

### ECS Tasks

Desired count:

- 2

### Task Definition

Container image:

- `bootcamp-api:day3`

---

## Docker / ECR

### ECR Repository

- `bootcamp-api`

### Available Tags

- `latest`
- `day2`
- `day3`

### Image Push

Successfully pushed:

- `day3`

---

## Application Verification

### Health Endpoint

```bash
curl http://<ALB_DNS>/health
```

Response:

```json
{"status":"healthy"}
```

### API Endpoint

```bash
curl http://<ALB_DNS>/api/hello
```

Response:

```json
{"message":"Hello from dev"}
```

### ECS Running Tasks

```bash
aws ecs describe-services \
  --cluster bootcamp-cluster \
  --services bootcamp-api-service \
  --query 'services[0].runningCount'
```

Result:

```text
2
```

---

## Issues Encountered

### ECR Immutable Tags

Issue:

- The `day2` tag already existed and could not be overwritten.

Fix:

- Created a new immutable image tag: `day3`

### Terraform Backend Warning

Warning:

- `dynamodb_table` is deprecated.

Status:

- Non-blocking
- Infrastructure functional

---

## Skills Practiced

- ECS Fargate deployment
- ALB configuration
- Security Group layering
- IAM role separation
- ECS Task Definitions
- CloudWatch logging
- Docker + ECR integration
- AWS networking architecture

---

## Conclusion

Successfully deployed a production-style containerized backend using AWS ECS Fargate with load balancing, secure networking, IAM integration, and centralized logging.
