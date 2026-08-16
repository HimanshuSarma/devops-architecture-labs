# Create VPC Terraform Module
module "vpc_a" {
  source  = "terraform-aws-modules/vpc/aws"
  #version = "3.11.0"
  #version = "~> 3.11"
  #version = "4.0.1"  
  version = "6.4.0"
  
  # VPC Basic Details
  name = var.vpc_a_name
  cidr = var.vpc_a_cidr_block
  azs             = data.aws_availability_zones.available.names
  public_subnets  = var.vpc_a_public_subnets
  private_subnets = var.vpc_a_private_subnets  

  create_database_subnet_group = var.vpc_create_database_subnet_group
  create_database_subnet_route_table = var.vpc_create_database_subnet_route_table
  # create_database_internet_gateway_route = true
  # create_database_nat_gateway_route = true
  
  # NAT Gateways - Outbound Communication
  enable_nat_gateway = var.vpc_enable_nat_gateway 
  single_nat_gateway = var.vpc_single_nat_gateway

  # VPC DNS Parameters
  enable_dns_hostnames = true
  enable_dns_support   = true

  
  tags = local.vpc_a_configs.common_tags
  vpc_tags = local.vpc_a_configs.common_tags

  # Additional Tags to Subnets
  public_subnet_tags = {
    Type = "vpc-a-public-subnets"
  }

  private_subnet_tags = {
    Type = "vpc-a-private-subnets"  
  }

  database_subnet_tags = {
    Type = "database-subnets"
  }

  # Instances launched into the Public subnet should be assigned a public IP address.
  map_public_ip_on_launch = true
}

resource "aws_vpc_peering_connection" "vpc_a_to_b" {
  # The ID of the VPC created by your module
  vpc_id        = module.vpc_a.vpc_id
  
  # The ID of the second VPC (the accepter)
  peer_vpc_id   = module.vpc_b.vpc_id
  
  # Auto-accept the peering (only works if both VPCs are in the same account)
  auto_accept   = true

  tags = {
    Name = "VPC Peering between A and B"
  }
}

resource "aws_route" "vpc_a_private_to_b" {
  # This creates a route for every private route table the module generated
  count                     = length(module.vpc_a.private_route_table_ids)
  route_table_id            = module.vpc_a.private_route_table_ids[count.index]
  destination_cidr_block    = var.vpc_b_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_a_to_b.id
}

# 3. Add the route to the PUBLIC route tables created by the module
resource "aws_route" "vpc_a_public_to_b" {
  count                     = length(module.vpc_a.public_route_table_ids)
  route_table_id            = module.vpc_a.public_route_table_ids[count.index]
  destination_cidr_block    = var.vpc_b_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_a_to_b.id
}