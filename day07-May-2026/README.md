## Networking flow
```mermaid
graph TD
    subgraph "The Global AWS Fabric (Underlay Network)"
        direction TB
        MappingService["<b>AWS Mapping Service</b><br/>(The Control Plane Brain)"]
        PhysicalBackbone["High-Speed Physical Fiber & Switches"]
    end

    subgraph "Physical Host Machine (Availability Zone A)"
        direction TB
        NitroCard["<b>AWS Nitro Card</b><br/>(Hardware-level Virtualization)"]
        Hypervisor["Lightweight Hypervisor"]
        
        subgraph "EC2 Instance OS (Guest Kernel)"
            direction LR
            RoutingTable["<b>Routing Table</b><br/>10.0.0.0/16 -> 'Local'"]
            NetworkDriver["Virtual ENA Driver"]
            BlockDriver["Virtual NVMe Driver"]
        end
    end

    subgraph "Regional Storage Services"
        EBS_Target[("<b>EBS Volume</b><br/>(Block Storage Rack)")]
        EFS_Endpoint{{"<b>EFS Mount Target</b><br/>(NFS Service Interface)"}}
    end

    %% Networking Logic
    EC2_Request_Net[Packet to 10.0.2.5] --> RoutingTable
    RoutingTable --> NetworkDriver
    NetworkDriver -- "Sends to .1 Gateway" --> NitroCard
    NitroCard -- "Interrogates" --> MappingService
    MappingService -- "Encapsulates Packet" --> PhysicalBackbone
    PhysicalBackbone -- "Tunnels to Target" --> SubnetB_EC2

    %% Storage Logic
    BlockDriver -- "SCSI/NVMe Cmds" --> NitroCard
    NitroCard -- "Direct Tunnel (Dedicated Fabric)" --> EBS_Target
    
    EC2_Request_File[File read/write] -- "NFS Protocol (TCP/IP)" --> NetworkDriver
    NetworkDriver -- "Standard Traffic" --> EFS_Endpoint

    %% Annotations
    style NitroCard fill:#f96,stroke:#333,stroke-width:2px
    style MappingService fill:#f96,stroke:#333,stroke-width:2px
    style RoutingTable fill:#fff,stroke:#333,stroke-dasharray: 5 5