# Day 05: Evidence

## Overview

This document contains the evidence collected during Day 05.

The goal of this lab was to improve the AWS application with production-oriented capabilities such as monitoring, alerts, secrets management, autoscaling, smoke testing, and automatic rollback.

---

## Evidence Summary

### 1. Terraform Apply

Terraform was executed successfully after importing existing AWS resources and fixing configuration drift.

**Validated resources:**

- ECS Service
- ECR Repository
- S3 Bucket
- CloudFront Distribution
- CloudWatch Alarms
- CloudWatch Dashboard
- SNS Topic and Email Subscription
- IAM Roles and Policies
- ECS Autoscaling Policy

**Evidence:**

- Screenshot of successful `terraform apply`
- Screenshot of Terraform outputs
- Screenshot of imported resources or Terraform state list

---

### 2. SSM Parameter Store

Application configuration was moved to AWS Systems Manager Parameter Store.

**Created parameters:**

- `/bootcamp/APP_ENV`
- `/bootcamp/DB_URL`

**Validation:**

- Backend application loaded configuration from SSM.
- Application failed fast when an invalid SSM parameter was used during rollback testing.

**Evidence:**

- Screenshot of SSM parameters
- Screenshot of backend `/health` response showing environment value

---

### 3. CloudWatch Alarms and SNS Email

CloudWatch alarms were created for ECS and ALB monitoring.

**Implemented alarms:**

- ECS high CPU utilization
- ALB 5xx errors
- ALB unhealthy hosts

SNS was configured to send notifications to email.

**Validation:**

- Manual alarm state change was triggered.
- SNS email notification was received successfully.
- Alarm was reset to OK state.

**Evidence:**

- Screenshot of CloudWatch alarm
- Screenshot of SNS email notification
- Screenshot of alarm reset command

---

### 4. CloudWatch Dashboard

A CloudWatch dashboard was created to monitor the application.

**Dashboard widgets:**

- ECS CPU Utilization
- ALB 5xx Errors
- ALB Request Count

**Validation:**

- Dashboard was created successfully.
- Metrics were visible in AWS CloudWatch.

**Evidence:**

- Screenshot of CloudWatch dashboard

---

### 5. ECS Backend Deployment

The backend service was deployed to ECS Fargate.

**Validation:**

- ECS service reached stable state.
- Desired count matched running count.
- Backend health endpoint responded successfully.

**Evidence:**

- Screenshot of ECS service stable
- Screenshot of running tasks
- Screenshot of `/health` response

---

### 6. Docker Image and ECR

A new Docker image was built and pushed to Amazon ECR.

**Validation:**

- Image was pushed successfully.
- ECS task definition referenced the correct image.
- ECS service was forced to redeploy using the updated image.

**Evidence:**

- Screenshot of ECR image list
- Screenshot of Docker push
- Screenshot of ECS new task definition revision

---

### 7. ECS Autoscaling

Application Autoscaling was configured for the ECS service.

**Configuration:**

- Minimum capacity: 2 tasks
- Maximum capacity: 6 tasks
- Scaling metric: ECS average CPU utilization
- Target value: 60%

**Validation:**

- Scaling policy was created successfully.
- AWS created the related target tracking alarms.

**Evidence:**

- Screenshot of autoscaling policy output
- Screenshot of target tracking alarms

---

### 8. GitHub Actions Backend Pipeline

The backend pipeline was improved with deployment safety.

**Implemented:**

- Test job
- Docker image build and push
- Dynamic image tag using Git commit SHA
- New ECS task definition revision
- ECS service update
- Deployment stability check
- Smoke test
- Automatic rollback on failure

**Validation:**

- Backend workflow executed successfully.
- New task definition revision was created.
- Smoke test passed.

**Evidence:**

- Screenshot of successful backend workflow
- Screenshot of successful ECS deployment step
- Screenshot of successful smoke test step

---

### 9. GitHub Actions Frontend Pipeline

The frontend pipeline deployed the production build to S3 and invalidated CloudFront.

**Validation:**

- Frontend workflow executed successfully.
- CloudFront served the frontend correctly.
- HTTP status returned 200.

**Evidence:**

- Screenshot of successful frontend workflow
- Screenshot of CloudFront URL response
- Screenshot of frontend smoke test

---

### 10. End-to-End Smoke Test

A smoke test script was created and executed.

**The script validated:**

- Backend `/health`
- Backend `/api/hello`
- Frontend CloudFront URL

**Validation result:**

- Backend health check passed.
- API endpoint responded successfully.
- Frontend returned HTTP 200.
- All checks passed.

**Evidence:**

- Screenshot of `./scripts/smoke-test.sh` output

---

### 11. Rollback Validation

A failed deployment was intentionally triggered by using an invalid SSM parameter.

**Test performed:**

- Replaced `/bootcamp/APP_ENV` with `/bootcamp/INVALID_PARAM`
- Pushed the broken backend change
- GitHub Actions deployed the broken revision
- ECS deployment failed to stabilize
- Rollback step executed automatically
- Previous healthy task definition was restored

**Validation:**

- The workflow failed as expected.
- Rollback was executed.
- The application remained healthy after rollback.

**Evidence:**

- Screenshot of failed GitHub Actions workflow
- Screenshot of rollback step execution
- Screenshot of `/health` response after rollback

---

## Final Verification

**Final status:**

- Backend healthy
- Frontend accessible
- ECS service stable
- CloudWatch alarms active
- SNS email notifications working
- Autoscaling policy active
- Smoke test passing
- Rollback mechanism validated
- GitHub Actions pipelines working

---

## Result

Day 05 was completed successfully.

The application now includes production-oriented operational features:

- Observability
- Monitoring
- Alerting
- Secure configuration
- Autoscaling
- Automated deployment
- Smoke testing
- Automatic rollback
- Infrastructure managed with Terraform
