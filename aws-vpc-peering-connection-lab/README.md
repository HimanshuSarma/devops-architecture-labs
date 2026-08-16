# AWS Inter-VPC Peering & Cross-Network Routing Lab

---

## 📄 Project Overview & Purpose

> ### **System Purpose**
> **Core Objective:** A hands-on networking lab demonstrating non-overlapping cross-VPC peering between two isolated Virtual Private Clouds (**VPC-A** and **VPC-B**) within the same AWS region (`us-east-1`). The project establishes direct, low-latency private IP connectivity across VPC boundaries using custom route tables, Internet Gateways (IGWs), NAT Gateways, and a **VPC Peering Connection (PCX)** without exposing traffic to the public internet.

---

## ⚡ Core Architecture & Key Features

* **Non-Overlapping Multi-VPC Topology**  
  Provisions **VPC-A** (`10.0.0.0/16`) and **VPC-B** (`10.1.0.0/16`) with distinct CIDR blocks to avoid IP collision and allow seamless cross-network routing.

* **Bidirectional VPC Peering (`PCX`)**  
  Establishes a active VPC Peering Connection between `VPC-A` and `VPC-B`, enabling private EC2 instances in both networks to communicate directly using internal IP addresses over AWS's high-speed backbone.

* **Explicit Route Table Configuration**  
  Configures static route targets in both networks to direct cross-VPC traffic appropriately:
  * **VPC-A Route Table:** Directs `10.1.0.0/16` traffic $\rightarrow$ `PCX`
  * **VPC-B Route Table:** Directs `10.0.0.0/16` traffic $\rightarrow$ `PCX`

* **Segmented Subnet & Gateway Architecture**  
  Each VPC contains **1 Public Subnet** (backed by an Internet Gateway) and **2 Private Subnets** (backed by a NAT Gateway), separating public-facing ingress points from secure internal workloads while maintaining egress internet access for software patches.

---

## 🏗️ Network & Subnet Matrix

| VPC Name | CIDR Block | Subnet Name | Subnet CIDR | Type | Gateway Association | Route Target to Peer |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **VPC-A** | `10.0.0.0/16` | Pub Subnet A | `10.0.0.0/24` | Public | Internet Gateway A (`IGW A`) | `10.1.0.0/16` $\rightarrow$ `PCX` |
| | | Priv Subnet A1 | `10.0.1.0/24` | Private | NAT Gateway A (`NAT A`) | `10.1.0.0/16` $\rightarrow$ `PCX` |
| | | Priv Subnet A2 | `10.0.2.0/24` | Private | NAT Gateway A (`NAT A`) | `10.1.0.0/16` $\rightarrow$ `PCX` |
| **VPC-B** | `10.1.0.0/16` | Pub Subnet B | `10.1.0.0/24` | Public | Internet Gateway B (`IGW B`) | `10.0.0.0/16` $\rightarrow$ `PCX` |
| | | Priv Subnet B1 | `10.1.1.0/24` | Private | NAT Gateway B (`NAT B`) | `10.0.0.0/16` $\rightarrow$ `PCX` |
| | | Priv Subnet B2 | `10.1.2.0/24` | Private | NAT Gateway B (`NAT B`) | `10.0.0.0/16` $\rightarrow$ `PCX` |

---

## 🔄 Inter-VPC Communication & Routing Flow

1. **Intra-VPC Public Access:** Public instances in `Pub Subnet A` or `Pub Subnet B` route inbound and outbound internet traffic through their respective Internet Gateways (`IGW A` / `IGW B`).
2. **Private Egress Access:** Internal instances in `Priv Subnets A1/A2` or `B1/B2` route outbound internet requests through their respective local NAT Gateways (`NAT A` / `NAT B`).
3. **Cross-VPC Traffic Flow:**
   * An instance in `VPC-A` (e.g., `10.0.1.10`) sends a request to an instance in `VPC-B` (`10.1.1.20`).
   * `VPC-A`'s route table matches the destination `10.1.0.0/16` and routes the packet to `PCX`.
   * The packet traverses the secure AWS peering connection into `VPC-B`.
   * `VPC-B` accepts the packet and routes it directly to the target private instance.

---

## 📐 System Architecture Diagram

```mermaid
graph TD
    subgraph Region ["AWS Region: us-east-1"]
        
        %% VPC A
        subgraph VPCA ["VPC-A (10.0.0.0/16)"]
            direction TB
            subgraph PubA ["Pub Subnet A (10.0.0.0/24)"]
                InstA_Pub[VPC-A-Instance]
            end
            subgraph PrivA1 ["Priv Subnet A1 (10.0.1.0/24)"]
                InstA_Priv1[Private Node]
            end
            subgraph PrivA2 ["Priv Subnet A2 (10.0.2.0/24)"]
                InstA_Priv2[Private Node]
            end
            
            IGW_A((IGW A))
            NAT_A[[NAT Gateway]]
            
            InstA_Pub --> IGW_A
            InstA_Priv1 & InstA_Priv2 --> NAT_A
            
            %% Routing Rule
            RouteA[<b>Route Table Entry:</b><br/>10.1.0.0/16 → PCX]
        end

        %% Peering Connection
        PCX((VPC Peering Connection))

        %% VPC B
        subgraph VPCB ["VPC-B (10.1.0.0/16)"]
            direction TB
            subgraph PubB ["Pub Subnet B (10.1.0.0/24)"]
                InstB_Pub[VPC-B-Instance]
            end
            subgraph PrivB1 ["Priv Subnet B1 (10.1.1.0/24)"]
                InstB_Priv1[Private Node]
            end
            subgraph PrivB2 ["Priv Subnet B2 (10.1.2.0/24)"]
                InstB_Priv2[Private Node]
            end
            
            IGW_B((IGW B))
            NAT_B[[NAT Gateway]]
            
            InstB_Pub --> IGW_B
            InstB_Priv1 & InstB_Priv2 --> NAT_B

            %% Routing Rule
            RouteB[<b>Route Table Entry:</b><br/>10.0.0.0/16 → PCX]
        end

        %% Connections
        VPCA <==> PCX
        PCX <==> VPCB
    end