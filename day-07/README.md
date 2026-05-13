# Day 06

## Objective
Provision a minimal EKS cluster with Terraform using the existing VPC infrastructure.

## Progress
- Created EKS control plane
- Created managed node group
- Configured OIDC provider
- Connected kubectl to the cluster
- Verified nodes and kube-system pods

## Blockers
- Kubernetes version 1.29 failed during node group creation because the requested AMI is no longer supported.
- Updated the cluster version to 1.30 and re-applied successfully.
- Terraform destroy was blocked by a stale remote state lock in DynamoDB after the previous operation. I verified the AWS identity and released the lock using terraform force-unlock, then retried the destroy.