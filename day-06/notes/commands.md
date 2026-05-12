# Day 06 - Commands

## Terraform

### Initialize Terraform

```bash
terraform init
```

### Format Terraform files

```bash
terraform fmt
```

### Validate configuration

```bash
terraform validate
```

### Review execution plan

```bash
terraform plan
```

### Apply infrastructure

```bash
terraform apply -auto-approve
```

### Force unlock Terraform state

```bash
terraform force-unlock <LOCK_ID>
```

### Destroy infrastructure

```bash
terraform destroy -auto-approve
```

---

## AWS

### AWS identity verification

```bash
aws sts get-caller-identity
```

### EKS kubeconfig

```bash
aws eks update-kubeconfig \
  --name bootcamp-eks \
  --region us-east-1
```

---

## Kubernetes

### Verify nodes

```bash
kubectl get nodes
```

### Verify pods

```bash
kubectl get pods -A
```
