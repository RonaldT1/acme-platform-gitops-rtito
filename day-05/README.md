# Day 05 - Production Monitoring, Autoscaling, and Deployment Rollback

## Objective

This project documents the implementation of production-grade operational capabilities for the AWS full-stack application deployed in previous labs.

The main objectives were:

- CloudWatch monitoring and alarms
- SNS email notifications
- ECS service autoscaling
- Backend health validation
- Smoke testing automation
- Deployment rollback strategy
- SSM Parameter Store integration
- Improved CI/CD reliability
- Production-safe ECS deployments

---

# Architecture

## Backend

- ECS Fargate for containerized backend execution
- Application Load Balancer (ALB) for traffic routing
- Amazon ECR for Docker image storage
- AWS Systems Manager Parameter Store (SSM) for configuration management
- CloudWatch Logs for centralized logging
- CloudWatch Alarms for monitoring
- ECS Service Autoscaling based on CPU utilization

## Frontend

- Amazon S3 for static frontend hosting
- CloudFront CDN distribution

## CI/CD

- GitHub Actions pipelines
- OIDC authentication between GitHub and AWS
- Automated backend deployment
- Automated frontend deployment
- Smoke tests after deployment
- Automatic rollback on failed deployments

## Infrastructure as Code

- Terraform for provisioning AWS infrastructure
- Modular Terraform configuration for ECS, networking, monitoring, autoscaling, and IAM

---

# Progress

## Monitoring and Observability

Implemented:

- CloudWatch Log Groups for ECS containers
- ECS CPU utilization alarm
- SNS topic and email subscription
- Alarm notifications via email

Validated:

- Alarm state transitions
- SNS email delivery
- CloudWatch log filtering

---

## SSM Parameter Store Integration

Integrated backend configuration using AWS SSM Parameter Store.

Implemented:

- Runtime configuration loading
- Environment variable management
- Fail-fast behavior when parameters are missing

Validation:

- Backend successfully loaded parameters from SSM
- Deployment failure triggered when invalid parameters were introduced

---

## ECS Autoscaling

Configured ECS Service Autoscaling using Application Auto Scaling.

Implemented:

- Minimum capacity: 2 tasks
- Maximum capacity: 6 tasks
- Target tracking scaling policy
- CPU utilization target: 60%

Validated:

- Scaling policy successfully attached to ECS service
- CloudWatch scaling alarms automatically created

---

## Backend Deployment Pipeline

Enhanced the GitHub Actions backend deployment pipeline.

Implemented:

- Automated Docker image build and push
- Dynamic ECS task definition revision creation
- ECS deployment stabilization checks
- Smoke test validation
- Automatic rollback strategy

Pipeline flow:

1. Run tests
2. Build Docker image
3. Push image to ECR
4. Create ECS task definition revision
5. Deploy ECS service
6. Wait for stable deployment
7. Run smoke test
8. Rollback automatically on failure

---

## Smoke Testing

Created an end-to-end smoke test script.

Validated:

- Backend `/health` endpoint
- Backend `/api/hello` endpoint
- Frontend CloudFront availability

Smoke test result:

- All checks passed successfully

---

## Rollback Validation

Performed a real rollback validation test.

Procedure:

- Introduced an invalid SSM parameter intentionally
- Triggered a backend deployment
- ECS tasks failed during startup
- GitHub Actions detected unstable deployment
- Automatic rollback restored the previous healthy task definition

Validation result:

- Rollback executed successfully
- Service recovered automatically
- `/health` endpoint remained healthy after rollback

---

# Verification

Successfully verified:

- ECS backend healthy
- Frontend accessible through CloudFront
- CloudWatch alarms functional
- SNS notifications delivered
- Autoscaling policy active
- Smoke tests successful
- Rollback automation working correctly
- GitHub Actions pipelines functional
- SSM integration operational

---

# Blockers

Issues encountered during implementation:

- GitHub Actions working-directory mismatches
- IAM permission limitations for ECS task definition operations
- Frontend build path confusion
- CloudFront deployment path issues
- ECS deployment stabilization delays
- SSM parameter validation failures

All issues were successfully resolved.

---

# Result

Successfully implemented a production-oriented AWS deployment environment including:

- ECS Fargate
- Application Load Balancer
- ECR
- CloudWatch monitoring
- SNS notifications
- ECS autoscaling
- SSM Parameter Store
- GitHub Actions CI/CD
- OIDC authentication
- Automated smoke testing
- Automatic deployment rollback
- CloudFront CDN
- Terraform infrastructure provisioning

The application now supports automated deployments, monitoring, autoscaling, observability, deployment validation, and automatic recovery from failed releases.