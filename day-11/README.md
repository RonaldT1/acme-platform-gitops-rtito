# Day 11 — EKS Karpenter Migration and Autoscaling

## Objective

Replace the legacy Cluster Autoscaler + Managed Node Group scaling model with Karpenter for faster and more flexible node provisioning in Amazon EKS.

The lab also validates:
- Dynamic node provisioning
- NodePools
- Spot/on-demand scheduling
- Node consolidation
- Interruption handling with SQS

---

# Architecture

Before:
- EKS Managed Node Group
- Cluster Autoscaler

After:
- Karpenter controller
- EC2NodeClass
- NodePools
- Dynamic EC2 provisioning
- Spot-aware scheduling
- Consolidation enabled

---

# Components Installed

## Karpenter
Installed via Helm into the `karpenter` namespace.

## NodePools
Created:
- `general`
- `gpu`

## EC2NodeClass
Defines:
- AMI family
- Subnets
- Security groups
- IAM role

## Interruption Queue
SQS queue configured for:
- Spot interruptions
- Rebalance recommendations
- Scheduled maintenance events

---

# Verification

## Verify Karpenter deployment

```bash
kubectl -n karpenter get deploy karpenter
```

Expected:
```bash
READY   UP-TO-DATE   AVAILABLE
2/2     2            2
```

---

## Verify NodePools

```bash
kubectl get nodepools
```

Expected:
```bash
NAME      READY
general   True
gpu       True
```

---

## Verify node labels

```bash
kubectl get nodes -L nodepool,karpenter.sh/capacity-type,topology.kubernetes.io/zone
```

Karpenter-provisioned nodes should expose:
- nodepool
- capacity type
- availability zone

---

## Verify consolidation logs

```bash
kubectl -n karpenter logs deploy/karpenter | grep -i consolidat
```

Example:
```text
deprovisioning via consolidation delete
```

---

## Verify interruption queue

```bash
aws sqs get-queue-attributes \
  --queue-url $(aws sqs get-queue-url --queue-name bootcamp-karpenter-interruption --query QueueUrl --output text) \
  --attribute-names ApproximateNumberOfMessages
```

Expected:
```json
{
  "Attributes": {
    "ApproximateNumberOfMessages": "0"
  }
}
```

---

# Key Concepts Learned

## Karpenter
Kubernetes-native node provisioning system for EKS.

Benefits:
- Faster scaling
- Better bin-packing
- Spot optimization
- Automatic consolidation
- Reduced infrastructure cost

---

## NodePools
Declarative scaling profiles used by Karpenter.

They define:
- instance requirements
- capacity type
- scheduling behavior

---

## Consolidation

Karpenter can:
- remove underutilized nodes
- replace expensive nodes
- optimize cluster cost automatically

Unlike Cluster Autoscaler, Karpenter actively optimizes node placement.

---

## Interruption Handling

Karpenter listens to EC2 interruption events through SQS and can:
- drain nodes
- reschedule workloads
- provision replacements automatically

Useful for:
- Spot instances
- Scheduled maintenance
- EC2 rebalance events

---

# Cleanup

Destroy infrastructure after validation:

```bash
terraform destroy
```

---

# Result

Successfully migrated EKS autoscaling from:
- Cluster Autoscaler
- Static Managed Node Groups

to:
- Karpenter
- Dynamic node provisioning
- Intelligent autoscaling
- Cost-aware scheduling