# ArgoCD GitOps & Progressive Delivery Lab

---

## 📄 Project Overview & Purpose

> ### **System Purpose**
> **Core Objective:** A hands-on infrastructure and deployment lab demonstrating end-to-end Kubernetes provisioning, declarative **GitOps bootstrapping via ArgoCD**, cluster-level add-on management, and progressive delivery patterns (**Blue/Green**, **Canary**, and **Rolling updates**) using **Argo Rollouts**.

---

## ⚡ Core Architecture & Key Features

* **Automated Cluster Provisioning & Bootstrap**  
  Provisions Kubernetes clusters (EKS/kubeadm) using **Terraform** and runs a **custom Bash script** on the master node to install **Helm** and prepare the control plane automatically.

* **Declarative GitOps Bootstrap via ArgoCD**  
  Installs and configures **ArgoCD** through Helm to serve as the single source of truth, declaratively managing cluster manifests, workloads, and system components directly from Git.

* **Cluster-Level Infrastructure Add-Ons**  
  Synchronizes essential cluster-level services as declarative ArgoCD applications:
  * **Networking & Ingress:** Calico CNI, NGINX Ingress Controller, and custom Ingress resources.
  * **Storage:** AWS EBS-CSI Controller for dynamic cloud volume provisioning.
  * **Observability:** Prometheus and Grafana stack for cluster metrics collection and visual dashboards.

* **Progressive Delivery Strategies (Argo Rollouts)**  
  Implements production-grade application deployment strategies to eliminate downtime and control risk:
  * **Blue/Green Strategy:** Deploys new revisions in parallel with active releases, requiring manual approval to promote live traffic.
  * **Canary Strategy:** Gradually shifts live user traffic incrementally to validate release stability.
  * **Rolling Updates:** Standard sequential pod replacement for zero-downtime updates.

---

## 🏗️ Implementation Flow & System Architecture

### 🔄 System Workflow

1. **Infrastructure & Bootstrap Layer**  
   * **Terraform** provisions the cluster infrastructure (EKS / kubeadm nodes).
   * A **custom Bash script** installs **Helm** on the master node.
   * **Helm** deploys **ArgoCD**, establishing the GitOps control plane.

2. **GitOps Add-On Management**  
   ArgoCD continuously monitors the repository and synchronizes key system services:
   * **Calico CNI:** Handles pod networking and network policies.
   * **NGINX Ingress Controller:** Manages external HTTP/HTTPS routing.
   * **EBS-CSI Driver:** Enables dynamic persistent storage provisioning.
   * **Prometheus & Grafana:** Provides cluster monitoring and metric aggregation.

3. **Progressive Delivery Engine**  
   **Argo Rollouts** manages workload deployments according to specific operational strategies:
   * **Blue/Green:** Runs validation on preview environments prior to manual traffic promotion.
   * **Canary:** Shifts traffic in controlled weight percentages.
   * **Rolling Update:** Replaces pods while enforcing `maxSurge` and `maxUnavailable` limits.

---

### 📐 System Architecture Diagram

```mermaid
flowchart TD
    subgraph Provisioning["1. Infrastructure & Bootstrap"]
        TF["Terraform"] -->|Provisions Cluster| K8s["Kubernetes Control Plane"]
        Script["Custom Bash Script"] -->|Installs Helm| K8s
        Helm["Helm"] -->|Deploys| Argo["ArgoCD Engine"]
    end

    subgraph GitOps["2. GitOps Add-On Synchronization"]
        Argo -->|Declarative Sync| Calico["Calico CNI"]
        Argo -->|Declarative Sync| Ingress["NGINX Ingress Controller"]
        Argo -->|Declarative Sync| CSI["EBS-CSI Driver"]
        Argo -->|Declarative Sync| Monitoring["Prometheus & Grafana"]
    end

    subgraph Rollouts["3. Progressive Delivery Strategies"]
        ArgoRollouts["Argo Rollouts Controller"]
        
        ArgoRollouts -->|Strategy A| BG["Blue/Green Deployment\n(Manual Promotion Gate)"]
        ArgoRollouts -->|Strategy B| Canary["Canary Deployment\n(Incremental Traffic Split)"]
        ArgoRollouts -->|Strategy C| Rolling["Rolling Update\n(Sequential Replacement)"]
    end