## Overview

Implementation including:

* Containerization using Docker
* CI pipeline using Jenkins
* EC2, VPC, ECR Infrastructure provisioning using Terraform
* Kubernetes deployment on AWS EKS
* Monitoring & logging
* Security scanning using Trivy
* Code quality scanning using SonarQube

---

## 📂 Repository Structure

```
app/            → Node.js application
docker/         → Dockerfile
ci/             → Jenkinsfile
iac/            → Terraform configuration
k8s/            → Deployment, Service, Ingress
monitoring/     → CloudWatch / Monitoring setup
```

---

## Task 1 - Application Setup

#### Install Dependencies

```
npm ci
```

#### Run Application

```
node app.js
```

App runs on:

```
http://localhost:3000
```

Health check endpoint:

```
http://localhost:3000/health
```


## Docker

#### Build Image
```
docker build -t nodejs-app .
```

#### Run Container
```
docker run -p 3000:3000 nodejs-app
```

#### Push to ECR
```
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <aws_account>.dkr.ecr.us-east-1.amazonaws.com
docker push $ECR_REPO:Latest
```

---

## TASK 2 - CI Flow

Jenkins → Checkout → Test → SonarQube check → Docker → Tag → Trivy → ECR

Images are tagged as:

* `<commit-sha>`
* `latest`
  
---

## TASK 3 - IAC
Terraform provisions VPC, IAM, ECR, and EC2 infrastructure.

#### Provisioned resources:

* VPC (Public + Private Subnets + Route table + Internet Gateway) 
* NAT Gateway
* IAM Roles
* ECR Repository
* EC2
* DynamoDB (Terraform state lock)
* S3 (Terraform state backend)

#### Terraform install command
```
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update -y 
sudo apt-get install terraform -y
```

#### Deploy Infrastructure

```
terraform init
terraform plan
terraform apply
```

#### Destroy Infrastructure

```
terraform destroy
```
---

## Task 4 -  Kubernetes Deployment

Resources included:

* Deployment (RollingUpdate strategy)
* Service (ClusterIP)
* ALB Ingress
* Liveness & Readiness Probes


## EKS create

#### Environ Setup 
```
sudo apt update -y
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl gpg socat
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl
sudo apt-mark hold kubectl
```

#### Eks setup
```
ARCH=amd64
PLATFORM=$(uname -s)_$ARCH
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
# (Optional) Verify checksum
curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" | grep $PLATFORM | sha256sum --check
tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz
sudo mv /tmp/eksctl /usr/local/bin
```

#### Install AWS-CLI
```
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/awass-cli --update
```

#### Create kubernetes cluster by using ekctl:
```
eksctl create cluster \
    --name task-eks-cluster \
    --version 1.35 \
    --nodegroup-name demo-nodes \
    --node-type t3.medium \
    --nodes 2 \
    --nodes-min 2 \
    --nodes-max 3 \
    --node-volume-size=20 \
    --region us-east-1 \
    --zones us-east-1a \
    --zones us-east-1b \
    --zones us-east-1c \
```
     
#### Config kubectl to connect to Amazon EKS cluster:
```
aws eks update-kubeconfig --name task-eks-cluster --region us-east-1
```

#### Helm Setup and Install ALB Controller
```
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
helm --version

helm repo add eks https://aws.github.io/eks-charts
helm repo update eks

eksctl utils associate-iam-oidc-provider \
    --region us-east-1 \
    --cluster task-eks-cluster \
    --approve

## Download and Create required policy and service account
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.14.1/docs/install/iam_policy.json
aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iam_policy.json

eksctl create iamserviceaccount \
--cluster=task-eks-cluster \
--namespace=kube-system \
--name=aws-load-balancer-controller \
--attach-policy-arn=arn:aws:iam::<aws_account>:policy/AWSLoadBalancerControllerIAMPolicy \
--override-existing-serviceaccounts \
--region us-east-1 \
--approve

## Install Alb controller
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=task-eks-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set vpcId=vpc-b4b35cc9 \
  --set region=us-east-1
```

#### Apply:

```
kubectl apply -f k8s/
```
---

## Task 5 -  Monitoring and Logging

CloudWatch Agent configured to:

* Monitor `/var/log/auth.log` and Send logs to CloudWatch Log.
* Capture Memory and Disk metrics from Ec2 server to Cloudwatch and display in dashboard

---

## Task 6 - Security Scan

* Trivy integrated into CI pipeline
* Fails build if HIGH/CRITICAL vulnerabilities detected

---
