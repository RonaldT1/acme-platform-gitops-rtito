# Day-18

## Terraform Outputs

- `cluster_name = bootcamp-rtito-day18-eks`
- `ecr_url = 711387135481.dkr.ecr.us-east-1.amazonaws.com/bootcamp-api`
- `github_actions_role_arn = arn:aws:iam::711387135481:role/bootcamp-rtito-day18-github-actions-role`

## Signing And Attestation Evidence

- `cosign verify` succeeded for:
  - `711387135481.dkr.ecr.us-east-1.amazonaws.com/bootcamp-api:56e4631b3535d090fc2dfd6d8a3d8888bd281d14`
- Verified digest:
  - `sha256:50f87354561ad61993f22b86c653421b289c62784d574354cef0384d1392ed02`
- Verified workflow identity:
  - repository: `amartinez-aquaware/bootcamp-2026-4`
  - workflow: `build-sign-attest.yml`
  - ref: `refs/heads/rtito-aquaware`
  - issuer: `https://token.actions.githubusercontent.com`
- `cosign verify-attestation --type cyclonedx` succeeded
- `cosign verify-attestation --type vuln` succeeded
- `rekor-cli search --sha ...` returned matching entries

## Kyverno Enforcement Evidence

- `kubectl get clusterpolicy`
  - `verify-bootcamp-api-signatures   ADMISSION=true   READY=True`
- Signed image test:
  - `kubectl apply -f test-signed-image.yaml`
  - `pod/signed-image-test created`
  - `kubectl get pod signed-image-test`
  - `1/1 Running`
- Unsigned image test:
  - a real image was built manually and pushed to ECR as `unsigned-test`
  - `kubectl apply -f test-unsigned-image.yaml`
  - request denied by Kyverno
  - failure reason: `no signatures found`

## SBOM Evidence

- `cosign download attestation $IMAGE | jq ... '.predicate.components | length'`
  - output included `648`
- This confirmed that the image SBOM contained a real component inventory well above the lab threshold of `> 100`.

## Real Problems And Workarounds

- Cosign attestations initially conflicted with ECR immutable tagging semantics.
  - Workaround: changed the repository to `MUTABLE`.
- The SLSA provenance workflow for a private repo required explicit private-repository handling and a stable ECR credential secret.
- Kyverno initially rejected the policy because the keyless attestor was missing an explicit Rekor URL.
- Kyverno initially failed against private ECR with `401 Unauthorized`.
  - Workaround: created `kyverno-ecr-creds` in namespace `kyverno` and referenced it from the policy.
- The first unsigned-image test used a missing tag and failed with `MANIFEST_UNKNOWN`.
  - Workaround: pushed a real unsigned image `unsigned-test` and repeated the test.
