# Day 16 — High-Level Steps

## 1. Clean the inherited repo

Removed capstone-specific artifacts from the previous day so the repo matched the Cilium lab scope.

## 2. Keep the base platform

Kept and normalized only the infrastructure still required:

- VPC
- EKS
- AWS Load Balancer Controller
- Karpenter
- ECR

## 3. Align the sample application

Updated the Node app and deployment manifests to support the paths the lab validates:

- `GET /api/items`
- `POST /api/login`
- `DELETE /api/items/:id`
- `GET /healthz`

## 4. Install Cilium in chained mode

Installed Cilium `1.19.4` in chained mode so AWS VPC CNI remained the primary IPAM and `aws-node` kept running.

## 5. Enable Hubble

Enabled Hubble Relay and Hubble UI successfully. The ALB ingress manifest was prepared but not completed because hostname and certificate ownership were left out of scope.

## 6. Apply L7 policy

Applied the `CiliumNetworkPolicy` for `bootcamp-api` in `bootcamp-excess-media`.

## 7. Verify traffic behavior

Validated policy behavior from `bootcamp-frontend`:

- `GET /api/items` -> `200`
- `POST /api/login` -> `200`
- `DELETE /api/items/1` -> `403`

The first attempt required troubleshooting:

- pods had to be restarted after Cilium installation to pick up chained mode networking
- the login request had to be sent as JSON instead of form data

## 8. Capture final evidence

Captured cluster health, policy validation, and the key blockers:

- removed deprecated Helm options from `cilium-values.yaml`
- skipped CLI-only checks because `cilium` and `hubble` were not installed locally
- left Hubble ingress completion pending environment-specific DNS and ACM details
