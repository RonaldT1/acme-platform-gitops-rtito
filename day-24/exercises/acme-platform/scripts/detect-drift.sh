#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../stacks/aws-legacy"
terraform init -backend-config=../../envs/sandbox/backend.hcl -reconfigure >/dev/null

if terraform plan -detailed-exitcode \
  -var-file=../../envs/sandbox/aws-legacy.tfvars \
  -var "db_password=$DB_PASSWORD" >/tmp/plan.out; then
  echo "No drift."
else
  rc=$?
  if [ "$rc" -eq 2 ]; then
    echo "DRIFT DETECTED:"
    cat /tmp/plan.out
    exit 2
  fi

  exit "$rc"
fi
