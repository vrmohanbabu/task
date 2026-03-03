## Containerization

A multi-stage Docker build was implemented to:

* Separate build and runtime environments
* Remove development dependencies
* Reduce image size
* Improve security by using non-root user

The final image runs only production dependencies and the compiled application.

---

## CI Pipeline 

Pipeline stages were structured to fail fast:

* Test before build
* Code quality scan before containerization
* Security scan before push
* Versioned image tagging for traceability

Git commit SHA is used as Docker image tag to ensure immutable deployments.

---

## Infrastructure as Code

Terraform was used to provision:

* Networking (VPC, subnets, Route table, NAT)
* ECR repository
* IAM roles
* EC2
* Remote state backend

S3 was used to store Terraform state, and DynamoDB was configured for state locking to prevent concurrent state corruption.

---

## Kubernetes Deployment Strategy

Deployment uses:

* RollingUpdate strategy (default)
* Readiness probe for zero-downtime deployment
* Liveness probe for auto-recovery

Service type ClusterIP was used with AWS ALB Ingress for routing and scalability.

---

## Monitoring & Logging

CloudWatch Agent was configured to monitor system logs.

Logs are sent to CloudWatch Log Groups using IAM role authentication.

---

## Security Practices

* No static AWS credentials
* Trivy integrated for container vulnerability scanning
* SonarQube integrated for code quality and security scanning

---
