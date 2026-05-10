#!/bin/bash
set -euo pipefail

INFRA_DIR="day-05/exercises/aws-bootcamp/infra"

ALB_DNS=$(terraform -chdir=$INFRA_DIR output -raw alb_dns)
CF_URL=$(terraform -chdir=$INFRA_DIR output -raw cloudfront_url)

echo "=== Backend Health ==="
curl -sf http://$ALB_DNS/health | jq .

echo "=== API Response ==="
curl -sf http://$ALB_DNS/api/hello | jq .

echo "=== Frontend ==="
HTTP_STATUS=$(curl -o /dev/null -s -w "%{http_code}" $CF_URL)
echo "CloudFront status: $HTTP_STATUS"
[ "$HTTP_STATUS" = "200" ] && echo "Frontend OK" || { echo "FAILED"; exit 1; }

echo "=== All checks passed ==="
