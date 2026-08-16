# Create VPC Terraform Module
module "vpc_b" {
  source  = "terraform-aws-modules/vpc/aws"
  #version = "3.11.0"
  #version = "~> 3.11"
  #version = "4.0.1"  
  version = "6.4.0"
  
  # VPC Basic Details
  name = var.vpc_b_name
  cidr = var.vpc_b_cidr_block
  azs             = data.aws_availability_zones.available.names
  public_subnets  = var.vpc_b_public_subnets
  private_subnets = var.vpc_b_private_subnets  

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

  
  tags = local.vpc_b_configs.common_tags
  vpc_tags = local.vpc_b_configs.common_tags

  # Additional Tags to Subnets
  public_subnet_tags = {
    Type = "vpc-b-public-subnets"
  }

  private_subnet_tags = {
    Type = "vpc-b-private-subnets"  
  }

  database_subnet_tags = {
    Type = "database-subnets"
  }

  # Instances launched into the Public subnet should be assigned a public IP address.
  map_public_ip_on_launch = true
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_b_attachment" {
  subnet_ids         = module.vpc_b.private_subnets
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway_vpc_a_b_c.id
  vpc_id             = module.vpc_b.vpc_id

  tags = {
    Name = "tgw-att-vpc-b"
  }
}

resource "aws_route" "vpc_b_private_to_other_vpcs" {
  # This creates a route for every private route table the module generated
  depends_on = [aws_ec2_transit_gateway.transit_gateway_vpc_a_b_c, aws_ec2_transit_gateway_vpc_attachment.vpc_b_attachment]
  count                     = length(module.vpc_b.private_route_table_ids)
  route_table_id            = module.vpc_b.private_route_table_ids[count.index]
  destination_cidr_block    = var.supernet_cidr_block
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway_vpc_a_b_c.id
}

# 3. Add the route to the PUBLIC route tables created by the module
resource "aws_route" "vpc_b_public_to_other_vpcs" {
  count                     = length(module.vpc_b.public_route_table_ids)
  depends_on = [aws_ec2_transit_gateway.transit_gateway_vpc_a_b_c, aws_ec2_transit_gateway_vpc_attachment.vpc_b_attachment]
  route_table_id            = module.vpc_b.public_route_table_ids[count.index]
  destination_cidr_block    = var.supernet_cidr_block
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway_vpc_a_b_c.id
}