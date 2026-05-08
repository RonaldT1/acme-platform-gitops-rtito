# Day 04 - Frontend Deployment + CI/CD Automation

## Objective

This project documents the implementation of deployment automation for a full-stack AWS application.

The main objectives were:

- Frontend deployment to S3
- CDN delivery with CloudFront
- GitHub Actions pipelines
- OIDC authentication between GitHub and AWS
- Automated backend deployment
- Automated frontend deployment

## Architecture

### Backend

- ECS Fargate for running the containerized backend
- Application Load Balancer for public traffic routing
- ECR for Docker image storage

### Frontend

- S3 for static frontend hosting
- CloudFront for CDN distribution

### CI/CD

- GitHub Actions for automation workflows
- OIDC for secure AWS authentication without long-lived credentials
- Terraform for AWS infrastructure provisioning

## Progress

### Backend CI/CD

- Created an ECS deployment pipeline.
- Built and pushed the Docker image to ECR.
- Updated the ECS service automatically from GitHub Actions.

### Frontend CI/CD

- Configured the React/Vite production build.
- Synced the frontend build output to S3.
- Added CloudFront invalidation after frontend deployment.

## Verification

- Backend endpoint OK
- Frontend URL OK
- Workflows successful

## Blockers

- GitHub Actions working-directory issues
- CloudFront distribution mismatch
- S3 AccessDenied policy issue

## Result

Successfully implemented a complete CI/CD workflow for a full-stack AWS application using GitHub Actions, ECS Fargate, ECR, S3, CloudFront, OIDC, and Terraform.
