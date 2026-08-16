# High-Availability Multi-Tier AWS VPC Architecture

---

## 📄 Project Overview & Purpose

> ### **System Purpose**
> **Core Objective:** A hands-on cloud network architecture lab demonstrating a secure, production-grade 3-tier VPC design in AWS. The project isolates application backends and databases in private subnets while using an **Nginx Reverse Proxy** in a public subnet and an **Internal Load Balancer (ILB)** with strict **NACL rules** to enforce defense-in-depth perimeter security.

---

## ⚡ Core Architecture & Key Features

* **Multi-Tier VPC Segmentation (`10.0.0.0/16`)**  
  Logically segregates cloud infrastructure into **1 Public Subnet** (`10.0.0.0/24`) and **2 Private Subnets** (`10.0.1.0/24` & `10.0.2.0/24`), ensuring strict operational isolation between public-facing and internal resources.

* **Reverse Proxy Edge Architecture**  
  Hosts an **Nginx Reverse Proxy** on a public EC2 instance to serve as the single public entry point, preventing direct external access to application servers and databases.

* **Internal Load Balancing & High Availability**  
  Deploys an **Internal Load Balancer (ILB)** within private subnets to distribute incoming API traffic across a **Target Group** of backend **Node.js** instances running on port `8000`.

* **Perimeter Defense & Network ACLs (NACLs)**  
  Private subnets are locked down using Network Access Control Lists (NACLs) and Security Groups:
  * Ingress to private subnets is strictly limited to **port `8000`** coming from the public proxy.
  * Internal database ports (e.g., PostgreSQL `5432`, MySQL `3306`, or Redis `6379`) are completely isolated and unreachable from outside the private perimeter.

---

## 🏗️ Network Configuration & Subnet Matrix

| Subnet Name | CIDR Block | Type | Deployed Resources | Allowed Ingress Traffic |
| :--- | :--- | :--- | :--- | :--- |
| **Public Subnet** | `10.0.0.0/24` | Public | Public EC2 Instance (Nginx Reverse Proxy / Frontend React) | External HTTP traffic on Port `8000` |
| **Private Subnet 1** | `10.0.1.0/24` | Private | Private EC2 Instance 1 (Node.js App) + Internal LB | Ingress on Port `8000` strictly from Public Subnet |
| **Private Subnet 2** | `10.0.2.0/24` | Private | Private EC2 Instance 2 (Node.js App) + PostgreSQL Database | Ingress on Port `8000` (App) / Port `5432` (Internal DB only) |

---

## 🔄 End-to-End Request & Traffic Flow

1. **Client Request:** The user's browser sends an API request to `http://[PUBLIC-EC2-IP]:8000`.
2. **Reverse Proxying:** The public Nginx EC2 instance intercepts the request and forwards it internally to the Internal Load Balancer.
3. **Internal Load Balancing:** The Internal Load Balancer receives the proxied request and routes it to an active node in the Target Group (Port `8000`).
4. **Backend Processing & DB Query:** Node.js instances in the private subnets process the request and securely query the internal PostgreSQL database over local private networking.

---

## 📐 System Architecture Diagram

```mermaid
graph TD
    subgraph Internet ["External Internet"]
        User((User Browser))
    end

    subgraph VPC ["VPC (10.0.0.0/16)"]
        direction TB

        subgraph Public_Subnet ["Public Subnet (10.0.0.0/24)"]
            Bastion[Public EC2 Instance<br/><b>Nginx Reverse Proxy</b>]
        end

        subgraph Private_Subnets ["Private Subnets (10.0.1.0/24 & 10.0.2.0/24)"]
            direction TB
            ILB[Internal Load Balancer]
            
            subgraph TG ["Target Group (Port 8000)"]
                App1[Private EC2 Instance 1<br/><b>Node.js Server</b>]
                App2[Private EC2 Instance 2<br/><b>Node.js Server</b>]
            end
            
            DB[(PostgreSQL DB)]
        end
    end

    %% Traffic Flow
    User -- "1. Request (Port 8000)" --> Bastion
    Bastion -- "2. Reverse Proxy" --> ILB
    ILB -- "3. Forwarding" --> TG
    TG --> App1
    TG --> App2
    App1 -.-> DB
    App2 -.-> DB

    %% Styling with Forced Black Text
    style Bastion fill:#f9f,stroke:#333,stroke-width:2px,color:#000
    style ILB fill:#bbf,stroke:#333,stroke-width:2px,color:#000
    style App1 fill:#bbf,stroke:#333,stroke-width:2px,color:#000
    style App2 fill:#bbf,stroke:#333,stroke-width:2px,color:#000
    style DB fill:#fdb,stroke:#333,stroke-width:2px,color:#000
    
    %% Label and Subgraph Styling
    style User color:#fff
    style Public_Subnet fill:#fff,stroke:#333,stroke-dasharray: 5 5,color:#000
    style Private_Subnets fill:#fff,stroke:#333,stroke-dasharray: 5 5,color:#000
    style TG fill:#444,color:#fff