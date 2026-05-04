# Commands used

## Node.js (local test)

node src/index.js
curl http://localhost:3000/health
curl http://localhost:3000/api/hello

---

## Docker

### Build image

docker build -f docker/Dockerfile -t bootcamp-api:local .

### Run container

docker run -d -p 3000:3000 -e APP_ENV=local --name bootcamp-api bootcamp-api:local

### Verify container

curl http://localhost:3000/health
curl http://localhost:3000/api/hello

### Check health status

docker inspect --format '{{.State.Health.Status}}' bootcamp-api

### Logs (debugging)

docker logs bootcamp-api

### Cleanup (optional)

docker stop bootcamp-api && docker rm bootcamp-api

---

## AWS (Bootcamp account)

### Verify identity

aws sts get-caller-identity

### Create S3 bucket (Terraform state)

aws s3 mb s3://$TFSTATE_BUCKET --region us-east-1

### Enable versioning

aws s3api put-bucket-versioning 
--bucket $TFSTATE_BUCKET 
--versioning-configuration Status=Enabled

### Create DynamoDB table (state locking)

aws dynamodb create-table 
--table-name terraform-lock 
--attribute-definitions AttributeName=LockID,AttributeType=S 
--key-schema AttributeName=LockID,KeyType=HASH 
--billing-mode PAY_PER_REQUEST 
--region us-east-1

### Check bucket contents

aws s3 ls s3://$TFSTATE_BUCKET/

---

## Terraform

### Initialize backend and providers

terraform init

### Validate configuration

terraform validate

### (Optional) Plan changes

terraform plan

---

## Git

### Check status

git status

### Add changes

git add .

### Commit

git commit -m "day-01: node api + docker + terraform backend"

### Push branch

git push
