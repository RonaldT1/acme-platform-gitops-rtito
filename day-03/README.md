# Day 03 — 2026-05-06

## Objective

Deploy the backend application to AWS ECS Fargate using:
- Application Load Balancer (ALB)
- Security Groups
- IAM Roles
- ECS Cluster + Service
- Docker image from ECR

---

## Context / setup

Previous infrastructure already completed:
- VPC
- Public and private subnets
- NAT Gateway
- ECR repository
- Dockerized Node.js API

AWS Region:
- us-east-1

---

## Progress

### Part 5
Created:
- ALB
- Target Group
- Listener
- Security Groups
- ECS IAM Roles

### Part 6
Created:
- ECS Cluster
- CloudWatch Logs
- ECS Task Definition
- ECS Fargate Service

---

## Verification

Successfully verified:
- ALB public access
- `/health` endpoint
- `/api/hello` endpoint
- ECS service stable
- Running tasks = 2

---

## Blockers

- ECR immutable tag conflict with `day2`
- Terraform backend deprecation warning

---

## Result

Backend application successfully deployed on AWS ECS Fargate behind an Application Load Balancer.