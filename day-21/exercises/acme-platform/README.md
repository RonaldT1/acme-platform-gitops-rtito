# acme-platform

Day 1 scaffold for the multi-env platform lab.

## Notes

- This project lives inside `day-21/exercises/acme-platform`; it is not a standalone Git repository.
- Terraform backend resource names use the `rtito` prefix.
- The backend bootstrap is the only Terraform configuration intended to run with local state.

## Layout

- `bootstrap/tf-backend`: creates the S3 bucket and DynamoDB table for remote state
- `envs/`: per-environment backend configuration
- `modules/`: reusable infrastructure modules
- `stacks/`: composed deployments per platform area
- `ci/`, `docs/`, `helm/`, `kustomize/`, `scripts/`, `provider-fortigate/`: supporting project structure
