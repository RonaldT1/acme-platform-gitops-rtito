# Day 01 — Deliverables

## 1. Node.js API

### Health endpoint

```bash
curl http://localhost:3000/health
```

**Result:**

```json
{ "status": "healthy", "timestamp": "..." }
```

### Hello endpoint

```bash
curl http://localhost:3000/api/hello
```

**Result:**

```json
{ "message": "Hello from local" }
```

---

## 2. Docker

### Image build

* Docker image built successfully using multi-stage Dockerfile

### Container running

```bash
docker ps
```

### Healthcheck

```bash
docker inspect --format '{{.State.Health.Status}}' bootcamp-api
```

**Result:**

```
healthy
```

---

## 3. AWS Backend (Terraform State)

### S3 Bucket

* Bucket created for Terraform remote state
* Versioning enabled

### DynamoDB

* Table `terraform-lock` available for state locking

---

## 4. Terraform

### Initialization

```bash
terraform init
```

**Result:**

```
Terraform has been successfully initialized!
```

### Validation

```bash
terraform validate
```

**Result:**

```
Success! The configuration is valid.
```

---

## 5. Key Outcome

* Node.js API containerized and running locally
* Docker healthcheck working correctly
* Remote Terraform backend configured:

  * S3 for state storage
  * DynamoDB for state locking
* Terraform initialized successfully with remote backend
