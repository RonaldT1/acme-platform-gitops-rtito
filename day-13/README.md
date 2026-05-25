# Day 13 — Vault on EKS with AWS KMS Auto-Unseal and External Secrets Operator

## Overview

In this lab, I deployed HashiCorp Vault on Amazon EKS using the official Helm chart and configured it to run in high availability mode with integrated Raft storage, TLS, persistent `gp3` volumes, and AWS KMS auto-unseal.

After initializing Vault, I enabled the KV v2 secrets engine, stored an application secret, configured Kubernetes authentication, and connected Vault with External Secrets Operator (ESO). Finally, I demonstrated secret rotation by updating a secret in Vault and verifying that ESO synchronized the new value into a Kubernetes Secret.

## Objectives

- Deploy Vault on EKS using Helm.
- Configure Vault with TLS using a self-signed lab CA.
- Enable Vault HA mode with three replicas.
- Use integrated Raft storage with persistent volumes.
- Configure AWS KMS auto-unseal through IRSA.
- Initialize Vault and securely handle recovery keys and root token.
- Enable the KV v2 secrets engine.
- Configure Kubernetes authentication in Vault.
- Install External Secrets Operator.
- Sync Vault secrets into Kubernetes Secrets.
- Demonstrate secret rotation.

## Architecture

```text
AWS KMS
  |
  | auto-unseal
  v
Vault on EKS
  |
  | Kubernetes Auth
  v
External Secrets Operator
  |
  | syncs secrets
  v
Kubernetes Secret
  |
  | envFrom secretRef
  v
bootcamp-api
```

## 1. Configure AWS KMS for Vault auto-unseal

I created the AWS KMS key and the IAM resources required for Vault to perform auto-unseal.

The goal of this step was to allow Vault to unlock itself automatically after pod restarts, avoiding manual unseal operations. Vault accesses AWS KMS through IRSA by using a Kubernetes ServiceAccount mapped to an IAM role.

## 2. Generate Vault TLS material

I generated a self-signed CA and used it to sign a Vault server certificate.

The certificate includes the Kubernetes DNS names needed by the Vault service, including:

- `vault.vault.svc.cluster.local`
- `vault.vault.svc`
- `vault`
- `*.vault-internal.vault.svc.cluster.local`

The generated TLS material was stored in a Kubernetes Secret named `vault-tls` in the `vault` namespace.

```bash
kubectl create namespace vault

kubectl -n vault create secret generic vault-tls \
  --from-file=tls.crt=vault.crt \
  --from-file=tls.key=vault.key \
  --from-file=ca.crt=vault-ca.crt
```

This enabled Vault to serve HTTPS traffic inside the cluster.

## 3. Install Vault HA with Raft and AWS KMS auto-unseal

I installed Vault using the official HashiCorp Helm chart and a custom `infra/vault-values.yaml` file.

Vault was configured with:

- TLS enabled
- 3 replicas
- HA mode
- Integrated Raft storage
- Persistent `gp3` volumes
- AWS KMS auto-unseal
- IRSA through the `vault` ServiceAccount
- Pod anti-affinity so replicas are scheduled on different nodes

```bash
helm repo add hashicorp https://helm.releases.hashicorp.com

helm upgrade --install vault hashicorp/vault \
  --namespace vault \
  --version 0.28.0 \
  -f infra/vault-values.yaml
```

The Vault pods were deployed as a StatefulSet:

- `vault-0`
- `vault-1`
- `vault-2`

Each pod uses persistent storage for Raft data.

## 4. Initialize Vault

After the Helm release was installed, I initialized Vault for the first time.

Because AWS KMS auto-unseal was enabled, Vault generated recovery keys instead of traditional unseal keys.

```bash
kubectl -n vault exec -it vault-0 -- vault operator init \
  -recovery-shares=5 \
  -recovery-threshold=3 \
  -format=json > vault-init.json
```

The `vault-init.json` file contains highly sensitive data:

- Vault root token
- Recovery keys

This file must be stored offline and must never be committed to Git or stored as a Kubernetes Secret.

I verified Vault status with:

```bash
kubectl -n vault exec -it vault-0 -- vault status
```

Expected result:

- `Sealed: false`
- `Storage Type: raft`
- `HA Enabled: true`
- `Active Node: true`

## 5. Enable KV v2 and store an application secret

I connected to Vault from my laptop using a local port-forward.

```bash
export VAULT_ADDR=https://127.0.0.1:8200
export VAULT_TOKEN=$ROOT
export VAULT_SKIP_VERIFY=true

kubectl -n vault port-forward svc/vault 8200:8200 >/dev/null &
```

> `VAULT_SKIP_VERIFY=true` is used only on the laptop side because the lab certificate does not include `127.0.0.1` or `localhost` in its SAN list.

Then I enabled the KV v2 secrets engine:

```bash
vault secrets enable -path=secret kv-v2
```

I stored a sample application secret at `secret/bootcamp/api`:

```bash
vault kv put secret/bootcamp/api \
  DB_URL='postgres://bootcamp:s3cret@db.internal:5432/app' \
  REDIS_URL='redis://cache.internal:6379' \
  JWT_SIGNING_KEY='change-me-soon'
```

## 6. Enable Kubernetes authentication

I enabled the Kubernetes auth method in Vault.

```bash
vault auth enable kubernetes
```

Then I configured Vault to validate Kubernetes ServiceAccount tokens against the in-cluster Kubernetes API server.

A long-lived token reviewer Secret was created for the Vault ServiceAccount:

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: vault-token-reviewer
  namespace: vault
  annotations:
    kubernetes.io/service-account.name: vault
type: kubernetes.io/service-account-token
EOF
```

Then I configured the Kubernetes auth method:

```bash
TOKEN_REVIEWER_JWT=$(kubectl -n vault get secret vault-token-reviewer -o jsonpath='{.data.token}' | base64 -d)
KUBE_CA_CERT=$(kubectl -n vault get secret vault-token-reviewer -o jsonpath='{.data.ca\.crt}' | base64 -d)

vault write auth/kubernetes/config \
  kubernetes_host="https://kubernetes.default.svc.cluster.local:443" \
  kubernetes_ca_cert="$KUBE_CA_CERT" \
  token_reviewer_jwt="$TOKEN_REVIEWER_JWT" \
  disable_iss_validation=true
```

This allows Vault to trust Kubernetes identities.

## 7. Create a Vault policy and Kubernetes auth role

I created a least-privilege policy that allows only read access to the `bootcamp/api` secret.

```hcl
path "secret/data/bootcamp/api" {
  capabilities = ["read"]
}

path "secret/metadata/bootcamp/api" {
  capabilities = ["read"]
}
```

Then I bound that policy to the `external-secrets` ServiceAccount in the `external-secrets` namespace.

```bash
vault write auth/kubernetes/role/bootcamp-api \
  bound_service_account_names=external-secrets \
  bound_service_account_namespaces=external-secrets \
  policies=bootcamp-api \
  ttl=1h
```

Only workloads using that specific ServiceAccount can authenticate to Vault with this role.

## 8. Install External Secrets Operator

I installed External Secrets Operator using Helm.

```bash
helm repo add external-secrets https://charts.external-secrets.io

helm upgrade --install external-secrets external-secrets/external-secrets \
  --namespace external-secrets \
  --create-namespace \
  --version 0.9.16 \
  -f infra/eso-values.yaml
```

ESO allows Kubernetes to synchronize secrets from external backends such as Vault.

The installation includes the required CRDs, including:

- `ClusterSecretStore`
- `ExternalSecret`

## 9. Configure Vault as a ClusterSecretStore

I created a `ClusterSecretStore` to tell ESO how to connect to Vault.

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: vault-backend
spec:
  provider:
    vault:
      server: https://vault.vault.svc.cluster.local:8200
      path: secret
      version: v2
      caBundle: |
        # base64-encoded vault-ca.crt
      auth:
        kubernetes:
          mountPath: kubernetes
          role: bootcamp-api
          serviceAccountRef:
            name: external-secrets
            namespace: external-secrets
```

This configuration tells ESO:

- where Vault is running
- which KV engine path to use
- which CA to trust
- how to authenticate using Kubernetes auth

## 10. Create an ExternalSecret for `bootcamp-api`

I created an `ExternalSecret` in the `bootcamp` namespace.

This resource tells ESO which values to read from Vault and how to create the Kubernetes Secret.

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: bootcamp-api
  namespace: bootcamp
spec:
  refreshInterval: 15s
  secretStoreRef:
    name: vault-backend
    kind: ClusterSecretStore
  target:
    name: bootcamp-api
    creationPolicy: Owner
    template:
      type: Opaque
      metadata:
        annotations:
          reloader.stakater.com/match: "true"
  data:
    - secretKey: DB_URL
      remoteRef:
        key: bootcamp/api
        property: DB_URL
    - secretKey: REDIS_URL
      remoteRef:
        key: bootcamp/api
        property: REDIS_URL
    - secretKey: JWT_SIGNING_KEY
      remoteRef:
        key: bootcamp/api
        property: JWT_SIGNING_KEY
```

ESO creates and maintains the Kubernetes Secret named `bootcamp-api`.

The application already consumes it through:

```yaml
envFrom:
  secretRef:
    name: bootcamp-api
```

## 11. Demonstrate secret rotation

To demonstrate secret rotation, I first watched the current Kubernetes Secret value:

```bash
watch -n2 'kubectl -n bootcamp get secret bootcamp-api -o jsonpath="{.data.JWT_SIGNING_KEY}" | base64 -d'
```

Then I updated the secret directly in Vault:

```bash
vault kv put secret/bootcamp/api \
  DB_URL='postgres://bootcamp:s3cret@db.internal:5432/app' \
  REDIS_URL='redis://cache.internal:6379' \
  JWT_SIGNING_KEY='rotated-2026-05-18'
```

Within the configured refresh interval, ESO synchronized the new value into the Kubernetes Secret.

The value changed from:

- `change-me-soon`
- `rotated-2026-05-18`

This proved that Vault is the source of truth and that ESO can keep Kubernetes Secrets updated.

### Important note about environment variables

The running `bootcamp-api` pod does not automatically receive updated values when secrets are consumed as environment variables. Environment variables are loaded when the container starts, so after rotating a secret the application pod must be restarted:

```bash
kubectl -n bootcamp rollout restart rollout/bootcamp-api
```

Alternatively, Stakater Reloader can be installed to trigger a rollout automatically when the Kubernetes Secret changes.

## Validation

Useful validation commands:

```bash
kubectl -n vault get pods
kubectl -n vault exec vault-0 -- vault status
kubectl -n vault exec vault-0 -- vault operator raft list-peers
kubectl -n external-secrets get pods
kubectl -n bootcamp get externalsecret
kubectl -n bootcamp get secret bootcamp-api
```

To decode a synced secret value:

```bash
kubectl -n bootcamp get secret bootcamp-api \
  -o jsonpath='{.data.JWT_SIGNING_KEY}' | base64 -d ; echo
```

## Cleanup

Because this lab runs on AWS resources, I destroyed the infrastructure after finishing validation.

```bash
terraform destroy
```

I also verified that no remaining AWS resources were left behind, such as EKS clusters, worker nodes, security groups, load balancers, or persistent volumes.

## Key learnings

- Vault can run on Kubernetes in HA mode using Raft storage.
- AWS KMS auto-unseal avoids manual unseal operations after pod restarts.
- IRSA allows Vault to use AWS permissions without static credentials.
- TLS is required so Vault can serve secure traffic inside the cluster.
- Kubernetes auth allows Vault to trust Kubernetes ServiceAccounts.
- External Secrets Operator can synchronize secrets from Vault into Kubernetes Secrets.
- Secret rotation updates the Kubernetes Secret, but pods using environment variables need a restart to consume the updated value.
- Least privilege is enforced by binding Vault policies to specific ServiceAccounts and namespaces.
