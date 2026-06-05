# Day-18

## High-Level Steps

1. Rebased the inherited environment to `day-18` across Terraform, Kubernetes manifests, and image references.
2. Recreated the AWS baseline with Terraform:
   - EKS `bootcamp-rtito-day18-eks`
   - ECR `bootcamp-api`
   - OIDC-backed GitHub Actions role for ECR access
3. Adapted the GitHub Actions workflow to the monorepo layout and private ECR repository.
4. Built and pushed the application image from GitHub Actions.
5. Signed the image keylessly with Cosign through GitHub Actions OIDC.
6. Published:
   - CycloneDX SBOM attestation
   - vulnerability attestation
   - SLSA provenance
7. Verified locally:
   - Cosign signature identity
   - CycloneDX attestation
   - vulnerability attestation
   - Rekor entries
   - image digest
8. Installed Kyverno in the cluster.
9. Created a `ClusterPolicy` to require keyless signatures for:
   - `711387135481.dkr.ecr.us-east-1.amazonaws.com/bootcamp-api:*`
10. Added ECR credentials for Kyverno so it could validate images from the private registry.
11. Validated admission control:
   - signed image admitted
   - unsigned image denied with `no signatures found`
12. Confirmed the SBOM evidence contained a real component inventory:
   - `648` components

## Real Blockers

- ECR was initially immutable, which broke repeated OCI attestation pushes from Cosign.
- The SLSA reusable workflow needed explicit handling for a private repository and stable ECR credentials.
- Kyverno initially rejected the keyless policy because `rekor.url` was missing.
- Kyverno initially failed to verify images in the private ECR repo with `401 Unauthorized`.
- The first unsigned-image test used a tag that did not exist, which only proved `MANIFEST_UNKNOWN` and not missing signatures.
