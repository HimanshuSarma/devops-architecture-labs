# 🚀 DevOps & Cloud Architecture Labs

A curated collection of production-grade DevOps, Cloud Infrastructure, CI/CD, and Infrastructure-as-Code (IaC) hands-on mini-projects. This repository showcases real-world architectural patterns, automated pipelines, and hybrid/multi-cloud deployments across **AWS, Azure DevOps, Kubernetes, Terraform, Ansible, and GitHub Actions**.

---

## 🧰 Core Tech Stack & Tools

| Area | Technologies |
| :--- | :--- |
| **Cloud Platforms** | AWS (VPC, EC2, EKS, Client VPN, S3), Azure DevOps |
| **CI/CD & Automation** | GitHub Actions, Azure DevOps Pipelines, Ansible |
| **Infrastructure as Code** | Terraform |
| **Containers & Orchestration** | Docker, Kubernetes (EKS, Manifest Deployment) |
| **Networking & Security** | AWS Client VPN (mTLS), Route Tables, Security Groups, SSH |

---

## 📂 Laboratory Catalog

Each lab below is fully documented with architecture diagrams, setup steps, and pipeline definitions in its respective directory.

| # | Lab Directory / Project | Key Concepts & Focus Areas | Tech Used |
| :-: | :--- | :--- | :--- |
| **01** | [**`aws-client-vpn-setup`**](./aws-client-vpn-setup) | Secure VPC access via Client VPN, mTLS certificates, subnet routing, and packet flow tracing. | AWS Client VPN, ACM, OpenVPN |
| **02** | [**`ci-cd-pipelines-with-github-actions-and-ansible`**](./ci-cd-pipelines-with-github-actions-and-ansible) | Automated configuration management, AWS EC2 Dynamic Inventory (`aws_ec2`), and pipeline caching. | GitHub Actions, Ansible, AWS EC2 |
| **03** | [**`azure-devops-kubernetes-terraform-pipeline`**](./azure-devops-kubernetes-terraform-pipeline) | End-to-end CI/CD for Java microservices, Terraform EKS provisioning, and K8s manifest deployments. | Azure DevOps, Terraform, Docker, EKS |
| **04** | [**`aws-multi-tier-vpc-lab`**](./aws-multi-tier-vpc-lab) | Multi-AZ VPC design, public/private subnet segmentation, and NAT Gateways. | AWS VPC, Subnets, Route Tables |
| **05** | [**`aws-transit-gateway-lab`**](./aws-transit-gateway-lab) | Hub-and-spoke VPC connectivity and centralized traffic management. | AWS Transit Gateway |
| **06** | [**`argo-gitops-lab`**](./argo-gitops-lab) | GitOps continuous deployment to Kubernetes clusters. | ArgoCD, Kubernetes |

---

## 🌟 Architectural Highlights

### 🔒 1. Zero-Trust Hybrid Connectivity
* Implemented mTLS-authenticated AWS Client VPN connections to access private EC2 compute resources without exposing endpoints to the public internet.

### ⚡ 2. Dynamic & Cached CI/CD Execution
* Built high-performance GitHub Actions & Azure DevOps pipelines leveraging layer caching for Python/Pip packages and Ansible Galaxy collections.
* Dynamic node discovery via AWS tags (`tag:Name=asg-app-node`) eliminating static IP dependencies.

### 🏗️ 3. Infrastructure as Code (IaC) Lifecycle
* Automated cloud resource provisioning using Terraform with remote S3 backend management and state locking.

---

## 🚀 How to Navigate This Repo

1. Navigate to any lab directory above via the links in the table.
2. Read the dedicated `README.md` inside each directory for step-by-step setup guides, pipeline configurations, and detailed architecture flowcharts.
3. Review the source code, playbooks, or pipeline YAML definitions directly inside each folder.