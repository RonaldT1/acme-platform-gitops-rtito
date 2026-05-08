# Day 04 - Evidence

## Infrastructure Overview

The Day 04 infrastructure extended the previous ECS backend deployment with automated CI/CD and frontend hosting.

Working components:

- Backend running on ECS Fargate
- Public access through an Application Load Balancer
- Docker images stored in ECR
- Frontend static files deployed to S3
- CloudFront serving the frontend as a CDN
- GitHub Actions authenticating to AWS through OIDC
- Terraform managing infrastructure updates

## GitHub Actions Pipelines

### deploy-backend.yml

This workflow automates the backend deployment process.

Main tasks:

- Authenticate to AWS using GitHub OIDC.
- Build the backend Docker image.
- Push the image to Amazon ECR.
- Update the ECS service.
- Wait for the ECS deployment to complete.

### deploy-frontend.yml

This workflow automates the frontend deployment process.

Main tasks:

- Authenticate to AWS using GitHub OIDC.
- Install frontend dependencies.
- Build the React/Vite frontend.
- Upload the `dist/` output to S3.
- Create a CloudFront invalidation.

## Backend Deployment Evidence

- ECS service updated successfully.
- Backend responded through the public endpoint.
- `curl` validations completed successfully.
- Backend workflow finished green in GitHub Actions.

## Frontend Deployment Evidence

- S3 upload completed successfully.
- CloudFront invalidation completed successfully.
- Frontend was accessible through the CloudFront URL.
- `curl -I` returned `HTTP/2 200 OK`.

## Issues Encountered

### Error 1 - GitHub Actions working-directory failure

Error:

```text
No such file or directory
```

Cause:

- Wrong relative paths inside the GitHub Actions workflows.
- Some steps were running from the wrong repository directory.

Fix:

- Corrected the `working-directory` configuration.
- Aligned backend and frontend commands with the actual project structure.

### Error 2 - frontend/dist not found

Error:

```text
frontend/dist does not exist
```

Cause:

- The workflow used an absolute repository path while already running inside the frontend working directory.
- This caused the upload step to look for the build output in the wrong location.

Fix:

- Switched the upload path to the relative `dist/` directory.
- Confirmed that the Vite build output was generated before the S3 sync step.

### Error 3 - CloudFront distribution mismatch

Error:

```text
NoSuchDistribution
```

Cause:

- The GitHub secret used an old CloudFront distribution ID.
- The workflow attempted to invalidate a distribution that no longer matched the active infrastructure.

Fix:

- Updated the `CF_DIST_ID` GitHub secret.
- Re-ran the frontend workflow with the correct distribution ID.

### Error 4 - CloudFront AccessDenied

Error:

```text
403 AccessDenied
```

Cause:

- The S3 bucket policy referenced the previous CloudFront distribution ARN.
- CloudFront was reaching the bucket, but the bucket policy did not trust the current distribution.

Fix:

- Ran `terraform apply` to update the bucket policy `SourceArn`.
- Terraform reconciled the policy with the active CloudFront distribution.
- Executed a CloudFront cache invalidation after the policy update.

### Error 5 - CloudFront DNS troubleshooting

Issue:

- CloudFront URL validation failed during troubleshooting.

Cause:

- Malformed URL variables.
- Hidden newline characters in shell output.
- Incorrect shell parsing while testing commands.

Fix:

- Validated the CloudFront domain using `terraform output`.
- Cleaned the URL value before running curl checks.
- Confirmed the final endpoint with direct HTTP validation.

## Final Validation

- Backend validated with `curl`.
- Frontend validated with `curl`.
- GitHub Actions workflows completed successfully.
- S3 objects were listed after deployment.
- CloudFront returned `HTTP/2 200 OK`.

## Skills Practiced

- GitHub Actions workflow design
- OIDC federation between GitHub and AWS
- CI/CD automation
- Backend deployment automation with ECS
- Docker image publishing to ECR
- Frontend deployment to S3
- CloudFront cache invalidation
- CloudFront troubleshooting
- S3 bucket policy debugging
- Terraform state reconciliation
- AWS IAM role and policy validation
- Environment variable and shell debugging

## Conclusion

Day 04 completed a production-style CI/CD workflow for a full-stack AWS application. The backend deployment was automated through ECR and ECS Fargate, while the frontend deployment was automated through S3 and CloudFront. The most valuable part of the work was resolving real DevOps issues around workflow paths, CloudFront distribution IDs, S3 access policies, and Terraform-managed infrastructure reconciliation.
