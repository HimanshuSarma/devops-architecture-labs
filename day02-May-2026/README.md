## Architecture Diagram

```mermaid
graph TD
    subgraph "AWS Region: us-east-1"
        
        %% VPC A
        subgraph "VPC-A (10.0.0.0/16)"
            direction TB
            subgraph "Pub Subnet A (10.0.0.0/24)"
                InstA_Pub[VPC-A-Instance]
            end
            subgraph "Priv Subnet A1 (10.0.1.0/24)"
                InstA_Priv1[Private Node]
            end
            subgraph "Priv Subnet A2 (10.0.2.0/24)"
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
        subgraph "VPC-B (10.1.0.0/16)"
            direction TB
            subgraph "Pub Subnet B (10.1.0.0/24)"
                InstB_Pub[VPC-B-Instance]
            end
            subgraph "Priv Subnet B1 (10.1.1.0/24)"
                InstB_Priv1[Private Node]
            end
            subgraph "Priv Subnet B2 (10.1.2.0/24)"
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
        VPC-A <==> PCX
        PCX <==> VPC-B
    end