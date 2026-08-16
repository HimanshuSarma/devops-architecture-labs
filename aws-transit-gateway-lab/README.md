# AWS Transit Gateway Hub-and-Spoke Architecture Lab

---

## 📄 Project Overview & Purpose

> ### **System Purpose**
> **Core Objective:** A hands-on enterprise cloud networking lab demonstrating centralized multi-VPC interconnection using **AWS Transit Gateway (TGW)**. The project eliminates the complexity and management overhead of full-mesh VPC peering by establishing a scalable **Hub-and-Spoke architecture** with optimized **supernet routing (`10.0.0.0/8`)** across multiple isolated Virtual Private Clouds in `us-east-1`.

---

## ⚡ Core Architecture & Key Features

* **Centralized Hub-and-Spoke Topology**  
  Replaces $N(N-1)/2$ complex, individual VPC peering connections with a single **AWS Transit Gateway** acting as a high-throughput cloud router connecting **VPC A**, **VPC B**, and **VPC C**.

* **Supernet CIDR Aggregation (`10.0.0.0/8`)**  
  Utilizes classless inter-domain routing (CIDR) supernetting to streamline route tables across all spokes. A single `10.0.0.0/8` target route entry directs all inter-VPC traffic to the Transit Gateway without requiring individual `/16` static routes.

* **Standardized Security Baselines**  
  Enforces uniform Security Group rules across compute targets (`EC2 INSTANCE A`, `B`, and `C`) allowing inbound administrative (SSH `22`) and web traffic (HTTP `80`, HTTPS `443`).

* **Direct Internet Ingress / Egress**  
  Equips each VPC with an **Internet Gateway (IGW)** to enable direct external access and software updates while routing internal cross-VPC communication exclusively over the private AWS backbone via TGW.

---

## 🏗️ Network & Routing Matrix

| VPC Name | CIDR Block | Deployed Compute Target | Security Group Ingress | Transit Gateway Route Target |
| :--- | :--- | :--- | :--- | :--- |
| **VPC A** | `10.0.0.0/16` | `EC2 INSTANCE A` | Ports `22` (SSH), `80` (HTTP), `443` (HTTPS) | `10.0.0.0/8` $\rightarrow$ `TGW` |
| **VPC B** | `10.1.0.0/16` | `EC2 INSTANCE B` | Ports `22` (SSH), `80` (HTTP), `443` (HTTPS) | `10.0.0.0/8` $\rightarrow$ `TGW` |
| **VPC C** | `10.2.0.0/16` | `EC2 INSTANCE C` | Ports `22` (SSH), `80` (HTTP), `443` (HTTPS) | `10.0.0.0/8` $\rightarrow$ `TGW` |

---

## 🔄 Traffic & Routing Flow

1. **Intra-VPC Traffic:** Local communication within `VPC A` (`10.0.0.0/16`) is routed locally by the VPC default route table.
2. **Cross-VPC Communication:**
   * `EC2 INSTANCE A` (`10.0.x.x`) initiates a connection to `EC2 INSTANCE B` (`10.1.x.x`).
   * The subnet route table matches the `10.0.0.0/8` supernet rule and forwards the packet to the local **TGW Attachment**.
   * **Transit Gateway** inspects its central route table and forwards the packet to `VPC B`'s attachment.
3. **Internet Access:** External web traffic enters and exits each spoke VPC directly via its dedicated **Internet Gateway (IGW)**.

---

## 📐 System Architecture Diagram

```mermaid
graph TD
    %% Theme settings for Cross-Mode Compatibility
    accTitle: AWS Transit Gateway Hub and Spoke Architecture
    accDescr: A diagram showing three VPCs connected via a central Transit Gateway with a Supernet route.

    subgraph Internet[" "]
        IGW(["<b>🌐 INTERNET GATEWAY</b>"])
    end

    subgraph AWS_Cloud["<b>☁️ AWS REGION (US-EAST-1)</b>"]
        
        TGW{{"<b>🛠️ TRANSIT GATEWAY</b><br/>(Central Hub)"}}

        subgraph VPC_A["<b>VPC A (10.0.0.0/16)</b>"]
            direction TB
            EC2_A["<b>EC2 INSTANCE A</b>"]
            SG_A["<b>SG: 22, 80, 443</b>"]
        end

        subgraph VPC_B["<b>VPC B (10.1.0.0/16)</b>"]
            direction TB
            EC2_B["<b>EC2 INSTANCE B</b>"]
            SG_B["<b>SG: 22, 80, 443</b>"]
        end

        subgraph VPC_C["<b>VPC C (10.2.0.0/16)</b>"]
            direction TB
            EC2_C["<b>EC2 INSTANCE C</b>"]
            SG_C["<b>SG: 22, 80, 443</b>"]
        end

        %% Thick Connections (Visible in all modes)
        VPC_A === TGW
        VPC_B === TGW
        VPC_C === TGW

        %% Supernet Route Labels
        TGW ==>|<b>ROUTE 10.0.0.0/8</b>| VPC_A
        TGW ==>|<b>ROUTE 10.0.0.0/8</b>| VPC_B
        TGW ==>|<b>ROUTE 10.0.0.0/8</b>| VPC_C
        
    end

    %% External Links
    IGW ==> VPC_A
    IGW ==> VPC_B
    IGW ==> VPC_C

    %% DYNAMIC STYLING (Works in Light/Dark)
    style TGW fill:#f90,stroke:#fff,stroke-width:4px,color:#000
    style IGW fill:#333,stroke:#fff,stroke-width:2px,color:#fff
    style AWS_Cloud fill:none,stroke:#888,stroke-width:2px,stroke-dasharray: 5 5
    
    style VPC_A fill:#444,stroke:#fff,stroke-width:3px,color:#fff
    style VPC_B fill:#444,stroke:#fff,stroke-width:3px,color:#fff
    style VPC_C fill:#444,stroke:#fff,stroke-width:3px,color:#fff
    
    style EC2_A fill:#666,stroke:#fff,color:#fff
    style EC2_B fill:#666,stroke:#fff,color:#fff
    style EC2_C fill:#666,stroke:#fff,color:#fff