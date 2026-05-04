# Day 01 — 2026-05-04

## Objective

Build a simple Node.js API, containerize it using Docker, and configure a Terraform remote backend using AWS (S3 + DynamoDB).

---

## Context / setup

* AWS account (bootcamp) configured using profile (`AWS_PROFILE=bootcamp`)
* WSL environment used for AWS CLI and Terraform
* Docker installed and running
* Git branch: `rtito-aquaware`

---

## Progress

* [x] Created Node.js API with `/health` and `/api/hello` endpoints
* [x] Built multi-stage Docker image
* [x] Ran container locally and verified endpoints
* [x] Implemented Docker healthcheck
* [x] Created S3 bucket for Terraform state
* [x] Enabled versioning on S3 bucket
* [x] Reused existing DynamoDB table for state locking
* [x] Configured Terraform backend (S3 + DynamoDB)
* [x] Ran `terraform init` successfully

---

## Notes and learnings

* Docker multi-stage builds help reduce image size and improve security
* Healthchecks allow validating container status automatically
* Terraform state should not be stored locally in team environments
* S3 is used to store Terraform state remotely
* DynamoDB is used for state locking to prevent concurrent modifications
* Switching between Windows and WSL can cause line ending (CRLF/LF) issues in Git
* AWS profiles help separate personal and organizational environments

---

## Blockers

* AWS CLI initially using personal account instead of bootcamp account
  → Fixed by configuring and exporting `AWS_PROFILE=bootcamp`

* Git showing modified files due to CRLF/LF differences
  → Resolved using `git restore` and proper Git configuration

* DynamoDB table creation failed (`already exists`)
  → Confirmed it can be reused safely

---

## Deliverable

* Node.js API running locally and containerized
* Docker image and container validated
* Terraform backend configured with:

  * S3 bucket (versioned)
  * DynamoDB table for locking
* `terraform init` completed successfully

---

## Next steps

* Define infrastructure resources using Terraform (e.g., VPC)
* Run `terraform plan` and `apply`
* Continue building infrastructure-as-code workflow
