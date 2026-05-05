# Day 02 — AWS Networking (VPC + ECR + First Container)

## 🎯 Objective

Build foundational AWS infrastructure using Terraform:

- Provision a VPC with public and private subnets across 2 AZs
- Configure Internet Gateway and NAT Gateway for networking
- Deploy an Amazon ECR repository
- Build and push a Docker image to ECR
- Understand real-world Terraform + AWS workflow

---

## 🧱 Architecture Overview

This day simulates a production-ready baseline:

- Public subnets → future Load Balancer (ALB)
- Private subnets → future ECS services
- NAT Gateway → outbound internet access for private workloads
- ECR → container registry for application images

---

## ✅ Completed Work

### Part 3 — VPC & Networking

- Created VPC (`10.0.0.0/16`)
- Configured:
  - 2 public subnets (multi-AZ)
  - 2 private subnets (multi-AZ)
  - Internet Gateway
  - NAT Gateway (public subnet)
- Route tables:
  - Public → IGW
  - Private → NAT Gateway

---

### Part 4 — ECR & Docker Image

- Created ECR repository with:
  - Image scanning enabled
  - Immutable tags
  - Lifecycle policy (keep last 10 images)

- Built Docker image locally
- Authenticated Docker with AWS ECR
- Tagged and pushed image:
  - `latest`
  - `day2`

---

## ⚠️ Blockers / Issues Encountered

### 1. Terraform output corruption (ECR_URL issue)

**Problem:**
- `terraform output` returned ANSI escape characters
- caused invalid Docker tag format

**Symptom:**
```bash
invalid reference format
```

**Cause:**
- CLI output included control characters (\x1b[33m)

**Fix:**
```bash
ECR_URL=$(terraform output -raw ecr_url | tr -d '"[:cntrl:]')
```

### 2. AWS SSO token expiration

**Problem:**
- ExpiredToken

**Fix:**
- Re-authenticated AWS session via SSO credentials refresh

### 3. Docker login error (wrong ECR URL format)

**Problem:**
- `$ECR_URL` was empty or malformed due to Terraform output issues

**Fix:**
- Ensured clean output using:
```bash
terraform output -raw ecr_url
```

### 4. Terraform destroy failure (ECR not empty)

**Problem:**
- RepositoryNotEmptyException

**Cause:**
- ECR contained pushed Docker images

**Fix:**
- Required manual or forced deletion

💡 **Final Fix Applied**

Added to Terraform:

```hcl
force_delete = true
```

This ensures:

- ECR can be destroyed even if images exist

---

## 🧠 Key Learnings

- Terraform state vs real AWS state can diverge in edge cases
- ECR is stateful (unlike VPC resources)
- CLI output formatting can break automation pipelines
- Docker + AWS authentication is sensitive to exact URL formatting
- Real DevOps work = debugging toolchain issues, not just infrastructure

---

## 🚀 Next Step

Day 03 will introduce:

- Security Groups
- Application Load Balancer (ALB)
- ECS fundamentals
- IAM roles for task execution
