# Day 08 — AWS Load Balancer Controller + Ingress

## Goal
Expose the `bootcamp-api` application publicly using an AWS Application Load Balancer managed through the AWS Load Balancer Controller and Kubernetes Ingress resources.

## What I worked on
- Added subnet tags for ELB discovery
- Created IRSA IAM role and policy for the AWS Load Balancer Controller
- Installed the controller using Helm
- Added `ingress.yaml` template to the Helm chart
- Enabled ingress support in `values.yaml`
- Deployed the application through Helm
- Verified ALB creation and ingress reconciliation
- Rebuilt and pushed the Docker image to ECR after infrastructure recreation
- Troubleshot ImagePullBackOff and ALB 503 issues

## Key Concepts Learned
- IRSA (IAM Roles for Service Accounts)
- AWS Load Balancer Controller
- Kubernetes Ingress
- ALB target registration
- Dynamic Helm values using Terraform outputs
- Why hardcoding infrastructure values is problematic

## Verification
- AWS Load Balancer Controller running successfully
- Ingress created successfully
- Public ALB DNS generated
- Application reachable through ALB
- `/health` and `/api/hello` endpoints responding correctly

## Notes
- Using dynamic values from Terraform outputs is safer than hardcoding ECR repository URLs.
- A running ALB with `503 Service Temporarily Unavailable` usually means backend targets are unhealthy or unavailable.
- `ImagePullBackOff` helped identify an incorrect ECR repository reference in the Helm values.

## Screenshots
Stored under:

```txt
notes/screenshots/
