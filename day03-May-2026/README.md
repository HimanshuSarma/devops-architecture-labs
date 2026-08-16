## Architecture Diagram

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