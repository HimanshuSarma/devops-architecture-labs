# AWS Under-the-Hood: Nitro Architecture, VPC Encapsulation & Storage Fabrics

---

## 📄 Project Overview & Purpose

> ### **System Purpose**
> **Core Objective:** An in-depth deep-dive architectural reference explaining the physical hardware and control plane mechanics powering AWS EC2 instances. This lab illustrates how the **AWS Nitro System**, **AWS Mapping Service**, hardware-level virtualization drivers (**ENA & NVMe**), VPC packet encapsulation, and storage fabric routing (**EBS vs. EFS**) operate under the hood.

---

## ⚡ Core Concepts & Architecture Breakdown

* **AWS Nitro System Hardware Offloading**  
  Replaces traditional software hypervisors with dedicated **Nitro Cards** to handle networking, security, and storage operations in hardware, freeing up 100% of the host CPU and memory for EC2 guest instances.

* **Underlay Network & Encapsulation Mapping**  
  Exposes the control-plane mechanics of VPC networking:
  * Guest OS routes packets to the virtual gateway (`.1`).
  * The **Nitro Card** queries the **AWS Mapping Service** to locate the physical MAC/IP address of the target host across the availability zone.
  * Packets are encapsulated and tunneled across AWS's physical fiber backbone directly to the target instance.

* **EBS vs. EFS Storage Processing Paths**  
  Contrasts low-latency block storage against network-attached file storage:
  * **EBS (Block Storage):** Translates OS SCSI/NVMe commands via virtual drivers to the Nitro Card, which routes traffic over a **dedicated, isolated storage fabric**.
  * **EFS (Shared File System):** Operates over standard TCP/IP networking using the NFS protocol via the instance's virtual **ENA network driver**.

---

## 📐 System Architecture Diagram

```mermaid
graph TD
    subgraph Fabric ["The Global AWS Fabric (Underlay Network)"]
        direction TB
        MappingService["<b>AWS Mapping Service</b><br/>(The Control Plane Brain)"]
        PhysicalBackbone["High-Speed Physical Fiber & Switches"]
    end

    subgraph Host ["Physical Host Machine (Availability Zone A)"]
        direction TB
        NitroCard["<b>AWS Nitro Card</b><br/>(Hardware-level Virtualization)"]
        Hypervisor["Lightweight Hypervisor"]
        
        subgraph GuestOS ["EC2 Instance OS (Guest Kernel)"]
            direction LR
            RoutingTable["<b>Routing Table</b><br/>10.0.0.0/16 -> 'Local'"]
            NetworkDriver["Virtual ENA Driver"]
            BlockDriver["Virtual NVMe Driver"]
        end
    end

    subgraph Storage ["Regional Storage Services"]
        EBS_Target[("<b>EBS Volume</b><br/>(Block Storage Rack)")]
        EFS_Endpoint{{"<b>EFS Mount Target</b><br/>(NFS Service Interface)"}}
    end

    %% Networking Logic
    EC2_Request_Net[Packet to 10.0.2.5] --> RoutingTable
    RoutingTable --> NetworkDriver
    NetworkDriver -- "Sends to .1 Gateway" --> NitroCard
    NitroCard -- "Interrogates" --> MappingService
    MappingService -- "Encapsulates Packet" --> PhysicalBackbone
    PhysicalBackbone -- "Tunnels to Target" --> SubnetB_EC2[Target EC2 Instance in Subnet B]

    %% Storage Logic
    BlockDriver -- "SCSI/NVMe Cmds" --> NitroCard
    NitroCard -- "Direct Tunnel (Dedicated Fabric)" --> EBS_Target
    
    EC2_Request_File[File read/write] -- "NFS Protocol (TCP/IP)" --> NetworkDriver
    NetworkDriver -- "Standard Traffic" --> EFS_Endpoint

    %% Annotations
    style NitroCard fill:#f96,stroke:#333,stroke-width:2px
    style MappingService fill:#f96,stroke:#333,stroke-width:2px
    style RoutingTable fill:#fff,stroke:#333,stroke-dasharray: 5 5