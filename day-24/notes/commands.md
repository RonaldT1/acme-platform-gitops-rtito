# Day-24 Commands

## Repository Inspection

```bash
cd ~/projects/bootcamp-2026-4/day-24
rg --files exercises/acme-platform
rg -n "module \"vpc\"|terraform \\{|required_providers|backend|provider \"google\"" \
  exercises/acme-platform -g '*.tf'
sed -n '1,220p' exercises/acme-platform/stacks/gcp-platform/main.tf
sed -n '1,220p' exercises/acme-platform/stacks/gcp-platform/variables.tf
sed -n '1,220p' exercises/acme-platform/stacks/gcp-platform/outputs.tf
sed -n '1,220p' exercises/acme-platform/stacks/gcp-platform/provider.tf
sed -n '1,220p' exercises/acme-platform/stacks/gcp-platform/versions.tf
sed -n '1,220p' exercises/acme-platform/modules/gcp-vpc/main.tf
sed -n '1,220p' exercises/acme-platform/modules/gcp-vpc/variables.tf
sed -n '1,220p' exercises/acme-platform/modules/gcp-vpc/outputs.tf
git -C exercises/acme-platform remote -v
find exercises/acme-platform -maxdepth 2 -type d | sort
```

## Code Changes

```bash
terraform fmt -recursive exercises/acme-platform
```

## Terraform Validation

```bash
terraform -chdir=~/projects/bootcamp-2026-4/day-24/exercises/acme-platform/stacks/gcp-platform \
  init -backend=false

terraform -chdir=~/projects/bootcamp-2026-4/day-24/exercises/acme-platform/stacks/gcp-platform \
  validate
```

Observed output:

```text
Success! The configuration is valid.
```

Environment note from this run:

```text
storage.NewClient() failed: dialing: credentials: could not find default credentials
```

## Kustomize Validation

```bash
kubectl kustomize \
  ~/projects/bootcamp-2026-4/day-24/exercises/acme-platform/kustomize/overlays/sandbox
```

Observed output highlights:

```text
namespace: rtito-hello-kustomize
replicas: 1
ENV=sandbox
```

## Tool Availability Checks

```bash
command -v helm
command -v kubectl
command -v argocd
command -v gcloud
```

Observed result:

```text
kubectl: /snap/bin/kubectl
helm: not installed
argocd: not installed
gcloud: not installed
```
