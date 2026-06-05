# Day-18

## Overview

Day 18 completed the supply chain security lab on top of the rebuilt AWS baseline:

- EKS `bootcamp-rtito-day18-eks`
- ECR `711387135481.dkr.ecr.us-east-1.amazonaws.com/bootcamp-api`
- GitHub Actions OIDC role for keyless signing
- Cosign signature verification against GitHub Actions identity
- CycloneDX SBOM attestation
- Vulnerability attestation
- Rekor transparency log evidence
- Kyverno admission policy enforcing signed images from the private ECR repo

## Outcome

The lab worked end to end with these verified results:

- GitHub Actions built, signed, and attested `bootcamp-api`
- `cosign verify` matched the expected GitHub workflow identity
- `cosign verify-attestation --type cyclonedx` succeeded
- `cosign verify-attestation --type vuln` succeeded
- `rekor-cli search --sha ...` returned matching transparency log entries
- Kyverno `ClusterPolicy` became `Ready=True`
- a signed image Pod was admitted and ran successfully
- a manually pushed unsigned image was blocked with `no signatures found`
- the downloaded SBOM evidence showed a real component count of `648`

## Real Problems And Fixes

- ECR was initially `IMMUTABLE`, which broke Cosign attestations because the same OCI attestation tag had to be updated more than once.
  Fix: changed the ECR repository to `MUTABLE`.
- The SLSA reusable workflow did not work cleanly with the transient ECR login output when the repository was private.
  Fix: used the private-repository setting and a dedicated GitHub secret for the ECR password generated from the correct AWS account.
- Kyverno rejected the initial keyless policy because it required an explicit Rekor URL.
  Fix: added `rekor.url: https://rekor.sigstore.dev`.
- Kyverno could not verify images from the private ECR repository at first because it had no registry credentials.
  Fix: created an ECR pull secret in namespace `kyverno` and referenced it from `imageRegistryCredentials`.
- The first negative Kyverno test used a non-existent tag and failed for `MANIFEST_UNKNOWN`, which was not strong enough as unsigned-image evidence.
  Fix: manually built and pushed a real `unsigned-test` image to ECR without Cosign signatures, then retried the admission test.

## References

- Steps: [CAPSTONE-STEPS.md](/home/ronald/projects/bootcamp-2026-4/day-18/CAPSTONE-STEPS.md)
- Evidence: [evidence.md](/home/ronald/projects/bootcamp-2026-4/day-18/deliverables/evidence.md)
- Commands: [commands.md](/home/ronald/projects/bootcamp-2026-4/day-18/notes/commands.md)
