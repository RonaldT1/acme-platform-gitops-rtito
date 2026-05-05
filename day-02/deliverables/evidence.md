# Day 02 — Evidence (AWS + Terraform + Docker)

## 🧱 Infrastructure Provisioned

### VPC
- CIDR: `10.0.0.0/16`
- 2 Public subnets (multi-AZ)
- 2 Private subnets (multi-AZ)

### Networking
- Internet Gateway attached
- NAT Gateway in public subnet
- Route tables configured:
  - Public → IGW
  - Private → NAT

---

## 📦 ECR Repository

- Repository name: `bootcamp-api`
- Image mutability: IMMUTABLE
- Image scanning: ENABLED
- Lifecycle policy: keep last 10 images

---

## 🐳 Docker Image

Built and pushed successfully:

- `latest`
- `day2`

### Push result:
- Image stored in AWS ECR
- Digest: `sha256:9de17eb1a08aa21cdbabc7f45c8fef0d06bbaf4a184c849ca3ac802355a5f074`

---

## 🔐 AWS Authentication

- AWS CLI authenticated via SSO
- Docker login successful using:
```bash
aws ecr get-login-password | docker login
```

---

## ⚠️ Issues Encountered

- **Terraform output corruption**
  - ANSI escape codes corrupted ECR URL
  - Fixed using `tr -d` cleanup

- **AWS SSO expired token**
  - Required re-authentication

- **ECR destroy failure**
  - Repository not empty due to pushed images
  - Fixed using `force_delete = true`

---

## 🧠 Skills Practiced

- Terraform infrastructure provisioning
- AWS VPC networking design
- NAT vs IGW understanding
- Docker image lifecycle
- ECR authentication flow
- Debugging CLI + cloud integration issues

---

## 📌 Conclusion

This day introduced real-world cloud engineering friction:

- Authentication issues
- State inconsistencies
- Resource deletion constraints

These are expected behaviors in production-like AWS environments and reinforce proper DevOps debugging skills.