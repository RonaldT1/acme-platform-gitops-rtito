# Day-24 Commands

## Repository Inspection

```bash
cd ~/projects/bootcamp-2026-4/day-24
rg --files exercises/acme-platform
sed -n '1,220p' exercises/acme-platform/stacks/gcp-platform/main.tf
sed -n '1,220p' exercises/acme-platform/stacks/gcp-platform/variables.tf
sed -n '1,220p' exercises/acme-platform/stacks/gcp-platform/outputs.tf
sed -n '1,220p' exercises/acme-platform/stacks/gcp-platform/provider.tf
sed -n '1,220p' exercises/acme-platform/stacks/gcp-platform/versions.tf
sed -n '1,220p' exercises/acme-platform/modules/gcp-vpc/main.tf
sed -n '1,220p' exercises/acme-platform/modules/gcp-vpc/variables.tf
sed -n '1,220p' exercises/acme-platform/modules/gcp-vpc/outputs.tf
git -C exercises/acme-platform remote -v
```

## Tool Setup

```bash
sudo snap install google-cloud-sdk --classic
sudo snap install helm --classic
curl -Lo argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd /usr/local/bin/argocd
rm argocd
```

Verification:

```bash
gcloud version
helm version
argocd version --client
gke-gcloud-auth-plugin --version
```

## Backend Bucket

```bash
gcloud storage buckets create gs://rtito-tfstate-$(gcloud config get-value project) \
  --location=us-central1 \
  --uniform-bucket-level-access

gcloud storage buckets update gs://rtito-tfstate-$(gcloud config get-value project) \
  --versioning

gcloud storage buckets describe gs://rtito-tfstate-$(gcloud config get-value project)
```

## Terraform Init And Apply

```bash
cd ~/projects/bootcamp-2026-4/day-24/exercises/acme-platform/stacks/gcp-platform
rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup

terraform init \
  -backend-config="bucket=rtito-tfstate-$(gcloud config get-value project)" \
  -backend-config="prefix=sandbox" \
  -reconfigure

terraform apply -var-file=../../envs/sandbox/gcp-platform.tfvars -auto-approve
```

Observed output highlights:

```text
Apply complete! Resources: 5 added, 0 changed, 0 destroyed.
cluster_name = "rtito-sandbox"
network_id = "projects/bootcamp-aquaware/global/networks/rtito-sandbox"
```

## Cluster Access

```bash
gcloud container clusters get-credentials rtito-sandbox --region us-central1
kubectl get nodes
```

Observed output highlights:

```text
gke-rtito-sandbox-rtito-sandbox-pool-...   Ready
```

## ArgoCD Install

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.12.4/manifests/install.yaml
kubectl get pods -n argocd
kubectl describe deploy argocd-server -n argocd
kubectl get events -n argocd --sort-by=.lastTimestamp
```

Initial failure observed:

```text
ImagePullBackOff
failed to pull image "quay.io/argoproj/argocd:v2.12.4"
dial tcp ...:443: i/o timeout
```

## NAT Fix For Private Nodes

```bash
terraform apply -var-file=../../envs/sandbox/gcp-platform.tfvars -auto-approve
kubectl delete pod -n argocd --all
kubectl get pods -n argocd -w
kubectl wait -n argocd --for=condition=available --timeout=300s deploy/argocd-server
argocd admin initial-password -n argocd
```

Observed output highlights:

```text
argocd-server-...                      1/1 Running
argocd admin initial-password -n argocd
0PYut6xbOAfRcl6n
```

## GitOps Source Repo

```bash
cd ~/projects/bootcamp-2026-4/day-24
git remote add gitops https://github.com/RonaldT1/acme-platform-gitops-rtito.git
gh auth switch -u RonaldT1
git add day-24
git commit -m "Add day-24 GKE ArgoCD lab"
git push gitops HEAD:main
```

## ApplicationSet Apply

```bash
cd ~/projects/bootcamp-2026-4/day-24/exercises/acme-platform
sed -i 's|https://github.com/amartinez-aquaware/bootcamp-2026-4.git|https://github.com/RonaldT1/acme-platform-gitops-rtito.git|' ci/argocd/applicationset.yaml
kubectl apply -f ci/argocd/applicationset.yaml
kubectl get applicationsets -n argocd
kubectl get applications -n argocd
kubectl describe application rtito-hello-sandbox-helm -n argocd
kubectl describe application rtito-hello-sandbox-kustomize -n argocd
kubectl get pods -A | grep hello
```

Observed output highlights:

```text
rtito-hello-sandbox-helm        Synced
rtito-hello-sandbox-kustomize   Synced

rtito-hello-helm        rtito-hello-sandbox-helm-...   1/1 Running
rtito-hello-kustomize   hello-...                      1/1 Running
```
