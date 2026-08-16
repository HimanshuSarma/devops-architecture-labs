DAY1 mini project: 1-mini-project

project description:
  i have 1 vpc(10.0.0.0/16)
  3 subnets:
    1 public(10.0.0.0/24) -> 1 instance in this subnet
    2 private: 10.0.1.0/24 and 10.0.2.0/24 -> 1 instance in each of these subnets
  
  so, i have total 3 intances in 3 subnets.

  i also have an internal Load Balancer that is sending traffic to a target group.
  the TARGET GROUP is the collection of the instances in the private subnets.

  the idea is i have the frontend(react app) in the public subnet.
  the nodejs server and db(postgres) in the public subnets

  the private subnets are protected by NACL rules.

  the frontend can only send traffic to the ec2 instances in the private subnets on port 8000(where nodejs server is running)
  
  the db ports(like 3306/5432) or maybe redis(6379) are not reachable from outside the private subnet.

  So, when the user hits an api request from the browser:

  Browser sends request to http://[public-ip]:8000 -> The public ip acts like a reverse proxy and sends the request to the internal LB
  internal LB -> sends the request to the target group listening on port 8000 -> the request is received by the nodejs server on the instances
  in the private subnet

  # High-Availability Multi-Tier VPC Architecture

  ## Architecture Diagram
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