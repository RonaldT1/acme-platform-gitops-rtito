# Day-18

## Lab Walkthrough

The Day 18 lab focused on container supply chain security for the `bootcamp-api` image in ECR.

The main technical work was:

- align the local baseline to the `day-18` environment naming and repository layout
- rebuild the AWS baseline with new Terraform state and names
- create a GitHub Actions OIDC role scoped to the repo and branch used in the lab
- adapt the image build workflow to the monorepo layout
- sign the image keylessly with Cosign through GitHub Actions
- publish CycloneDX SBOM and vulnerability attestations
- verify signature, attestations, digest, and Rekor entries locally
- install Kyverno and enforce signed-image admission on the private ECR repo
- prove that a signed image is admitted and an unsigned image is denied

The most important troubleshooting results were:

- changing ECR mutability to support repeated OCI attestation pushes
- fixing the private-repo SLSA workflow inputs and ECR credentials
- adding Rekor explicitly to the Kyverno keyless rule
- giving Kyverno ECR credentials so it could verify images in a private registry

The final validation ended with these real outcomes:

- signed image admitted and running
- unsigned image denied with `no signatures found`
- SBOM evidence showed `648` components
