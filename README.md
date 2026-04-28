```markdown
# much-to-do-infra

Terraform infrastructure for the Much-To-Do full-stack application.

**Live:** https://dfjvg2100os8x.cloudfront.net

---

## Architecture

```text
Internet
   │
   ├── HTTPS ──► CloudFront ──► S3 (React SPA)
   │                 │
   │              /api/* ───────────────► ALB :80
   │                                      │
   └────────────── VPC (10.0.0.0/16) ─────┘

        Public Subnets (2 AZs)
        - NAT Gateways
        - ALB

        Private Subnets (2 AZs)
        - EC2 Backend x2 :8080
        - EC2 MongoDB :27017
        - ElastiCache Redis :6379
```

· EC2 ──► CloudWatch Logs
· EC2 ──► Systems Manager (no SSH)

CloudFront serves static assets from S3 and routes /api/* to the ALB.
The ALB distributes traffic across backend instances in separate availability zones.
Backend services run in private subnets with no public exposure.

---

Structure

```text
much-to-do-infra/
├── main.tf
├── variables.tf
├── outputs.tf
├── backend.tf
├── modules/
│   ├── security/
│   ├── networking/
│   ├── compute/
│   ├── database/
│   └── frontend/
├── userdata/
│   └── backend.sh
```

---

Deployment

Bootstrap remote state (S3 + DynamoDB), then:

```bash
git clone https://github.com/Techypoetic/much-to-do-infra.git
cd much-to-do-infra
terraform init
```

Create terraform.tfvars (do not commit):

```hcl
db_username = "admin"
db_password = "..."
jwt_secret  = "..."
```

Apply:

```bash
terraform plan
terraform apply
terraform output
```

---

CI/CD

Pipelines are defined in the application repository:
https://github.com/Techypoetic/much-to-do

· Frontend: builds React app, uploads to S3, invalidates CloudFront
· Backend: rolling deploy via SSM (pull, build, restart service)

---

Observability

· CloudWatch Logs: /much-to-do/backend
· One log stream per instance

---

Teardown

```bash
terraform destroy
```

Remote state resources are managed separately.

---

Repositories

· much-to-do-infra — Infrastructure
· much-to-do — Application

```