# Day-24

## Day 4 - GKE Cluster + ArgoCD Bootstrap + Helm vs Kustomize

## Status

- Step 1 completed:
  - created `modules/gke-cluster` with separated `versions.tf`, `variables.tf`, `main.tf`, and `outputs.tf`
  - preserved the `rtito` naming convention in the GCP stack
- Step 2 completed:
  - created the GCS backend bucket manually for this lab run
  - applied `stacks/gcp-platform`
  - created the `rtito-sandbox` VPC and GKE cluster
- Step 3 completed:
  - installed ArgoCD in namespace `argocd`
  - added Cloud NAT to the GCP VPC module to give private GKE nodes egress
  - ArgoCD pods became healthy after NAT was applied
- Steps 4 and 5 completed:
  - Helm app under `helm/hello`
  - Kustomize base and sandbox overlay under `kustomize/`
- Step 6 completed:
  - applied `ci/argocd/applicationset.yaml`
  - switched the GitOps source to a public repo to avoid private repo authentication issues
  - both the Helm and Kustomize applications synced successfully

## Captured Evidence

- GKE apply outputs:
  - `cluster_name = "rtito-sandbox"`
  - `network_id = "projects/bootcamp-aquaware/global/networks/rtito-sandbox"`
- Cluster access verification:
  - `gcloud container clusters get-credentials rtito-sandbox --region us-central1`
  - `kubectl get nodes` returned three `Ready` nodes
- ArgoCD installation verification:
  - all pods in `argocd` reached `Running`
  - `argocd admin initial-password -n argocd` returned `0PYut6xbOAfRcl6n`
- GitOps application verification:
  - `kubectl get applications -n argocd` showed:
    - `rtito-hello-sandbox-helm        Synced`
    - `rtito-hello-sandbox-kustomize   Synced`
  - Helm application sync result:
    - namespace `rtito-hello-helm` created
    - service `rtito-hello-sandbox-helm` created
    - deployment `rtito-hello-sandbox-helm` created
  - Kustomize application sync result:
    - namespace `rtito-hello-kustomize` created
    - service `hello` created
    - deployment `hello` created
- Workload verification:
  - `kubectl get pods -A | grep hello` returned:
    - `rtito-hello-helm        rtito-hello-sandbox-helm-...   1/1 Running`
    - `rtito-hello-kustomize   hello-...                      1/1 Running`

## Notes

- The GCS backend bucket was created manually because this lab only needed a single bootstrap resource.
- The inherited `envs/sandbox/backend.hcl` file is for the AWS `s3` backend and does not apply to `stacks/gcp-platform`, which uses `backend "gcs" {}`.
- The first ArgoCD install attempt failed with `ImagePullBackOff` because private GKE nodes had no Internet egress. This was fixed by adding Cloud Router and Cloud NAT to `modules/gcp-vpc`.
- The original GitOps source repo was private and inaccessible to ArgoCD. The working fix was to publish the lab content to the public repo:
  - `https://github.com/RonaldT1/acme-platform-gitops-rtito.git`
- The ArgoCD CLI login through `kubectl port-forward` remained unstable in WSL, but it did not block the lab because application creation and verification were completed with `kubectl`.
