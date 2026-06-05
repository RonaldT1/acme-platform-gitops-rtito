# Day-18

## Runbook Summary

This repo completed the supply chain security lab on top of the Day 18 EKS baseline.

### Completed Scope

- Terraform rebuilt the `day18` infrastructure
- GitHub Actions built and pushed `bootcamp-api`
- Cosign keyless signing succeeded through GitHub Actions OIDC
- CycloneDX SBOM attestation published
- vulnerability attestation published
- Rekor transparency log entry verified
- Kyverno installed successfully
- `ClusterPolicy` enforced signatures for `bootcamp-api` images in private ECR
- signed image admission passed
- unsigned image admission failed

### Final Validation

- `cosign verify` succeeded for the signed image
- attestation verification succeeded for `cyclonedx` and `vuln`
- `kubectl get clusterpolicy` showed `READY=True`
- `signed-image-test` reached `Running`
- `unsigned-image-test` was denied with `no signatures found`
- SBOM component count reached `648`

### Residual Gaps

- The optional lab step was not required to complete the core exercise.
- ECR auth for Kyverno depends on a manually created registry secret, so it should be recreated after cluster rebuilds.
