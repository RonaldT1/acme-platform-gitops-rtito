# Day 10 — EKS GitOps, HPA and Cluster Autoscaler

## Overview

In this lab I deployed a containerized application into Amazon EKS using GitOps practices with ArgoCD, Helm and Terraform.

The environment included:

* Amazon EKS cluster
* AWS Load Balancer Controller
* ArgoCD
* Horizontal Pod Autoscaler (HPA)
* Cluster Autoscaler
* GitOps workflow using a separate Git repository

I also simulated a broken deployment and validated automatic rollback through Git revert and ArgoCD reconciliation.

## Technologies Used

* Terraform
* Amazon EKS
* Kubernetes
* Helm
* ArgoCD
* AWS Load Balancer Controller
* Cluster Autoscaler
* Horizontal Pod Autoscaler
* Amazon ECR
* GitHub
* Docker

## What Was Implemented

### Infrastructure

Provisioned with Terraform:

* VPC
* Public and private subnets
* Internet Gateway and NAT Gateway
* EKS cluster
* Managed node group
* IAM roles and IRSA
* ECR repository
* Kubernetes add-ons

Installed and configured:

* AWS Load Balancer Controller
* Metrics Server
* ArgoCD
* Cluster Autoscaler

### Application Deployment

Deployed the bootcamp-api application using:

* Helm chart
* GitOps repository
* ArgoCD synchronization

### HPA Load Test

Generated continuous traffic against the ALB endpoint:

```bash
kubectl run -it --rm load --image=busybox --restart=Never -- \
  sh -c "while true; do wget -q -O- http://$ALB/api/hello; done"
```

Observed:

* CPU utilization increase
* HPA scaling replicas from 2 toward higher replica counts
* Cluster Autoscaler activity during workload spikes

### Verification Commands

```bash
kubectl -n bootcamp get hpa -w
kubectl get nodes -w
```

## GitOps Rollback Simulation

Modified the GitOps repository and changed:

```yaml
image:
  tag: does-not-exist
```

Committed and pushed the broken configuration:

```bash
git add .
git commit -m "day-10: simulate broken gitops deployment"
git push
```

Result:

* ArgoCD synchronized automatically
* New pods entered: ErrImagePull, ImagePullBackOff

Rollback was performed using:

```bash
git revert HEAD
git push
```

ArgoCD reconciled the application automatically and restored healthy running pods.

## Validation

### ArgoCD

Verified:

* Application status: Healthy
* Sync status: Synced

### Kubernetes

Verified:

* Pods returned to Running
* Rollout history available
* HPA reacting to load

Commands used:

```bash
kubectl -n bootcamp get pods
kubectl -n bootcamp rollout history deploy/bootcamp-api
kubectl -n bootcamp get hpa bootcamp-api
```

## Troubleshooting Notes

During infrastructure cleanup:

* Terraform destroy initially failed due to remaining AWS Load Balancers and Security Groups created by the AWS Load Balancer Controller.
* Manual cleanup of ALBs and orphaned Security Groups was required before the VPC could be deleted successfully.

This demonstrated real-world AWS dependency and cleanup behavior when working with:

* EKS
* ALB Controller
* Terraform destroy operations

## Cleanup

Infrastructure destroyed using:

```bash
terraform destroy
```

Additional manual cleanup included:

* ALB deletion
* Security Group cleanup
* Terraform state lock recovery

## Key Learnings

* GitOps reconciliation with ArgoCD
* HPA behavior under load
* Cluster Autoscaler scaling patterns
* IRSA integration
* Helm-based Kubernetes deployments
* Troubleshooting AWS dependency violations
* Terraform remote state locking behavior
* Real-world EKS cleanup challenges
