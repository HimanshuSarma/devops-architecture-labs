resource "aws_ec2_transit_gateway" "transit_gateway_vpc_a_b_c" {
  description = "Main Transit Gateway for VPC-A, VPC-B, VPC-C"
  
  # Enabling these allows VPCs to automatically see each other 
  # without manual TGW route table entries.
  default_route_table_association = "enable"
  default_route_table_propagation    = "enable"

  tags = {
    Name = "transit_gateway_vpc_a_b_c"
  }
}