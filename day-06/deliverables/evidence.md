# Day 06 - Evidence (AWS EKS + Terraform)

## Objective

Provision a minimal EKS cluster using Terraform on top of the existing VPC infrastructure.

---

## EKS Cluster

### Cluster details

- Cluster name: `bootcamp-eks`
- Kubernetes version: `1.30`
- Region: `us-east-1`

---

## Node Group

Managed node group created successfully:

- Desired nodes: `2`
- Instance type: `t3.medium`
- Status: `Ready`

---

## kubectl Verification

### Nodes

- 2 worker nodes in `Ready` status

### System pods

Core components running successfully:

- `aws-node`
- `coredns`
- `kube-proxy`

---

## IAM / OIDC

Configured successfully:

- EKS Cluster IAM Role
- EKS Node IAM Role
- OIDC Provider for IRSA support

---

## Blockers Encountered

### Kubernetes version compatibility

Issue:

- EKS node group creation failed using Kubernetes version `1.29`

Reason:

- Requested AMI version was no longer supported by AWS

Resolution:

- Updated cluster version to `1.30`
- Re-applied Terraform successfully

### Terraform state lock

Issue:

- Terraform destroy was blocked by a stale DynamoDB state lock

Resolution:

- Released the lock using Terraform force unlock
- Re-ran destroy successfully

---

## Cleanup

Infrastructure destroyed successfully after validation.
