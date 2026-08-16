locals {
  target_vpcs = {
    vpc_a = module.vpc_a.vpc_id
    vpc_b = module.vpc_b.vpc_id
    vpc_c = module.vpc_c.vpc_id
  }
}

resource "aws_security_group" "public_instance_sg" {

  for_each = local.target_vpcs

  name        = "public_instance_sg"
  description = "Allow web traffic from the internet"
  vpc_id      = each.value

  # Inbound Rule: HTTP
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound Rule: HTTPS
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound: Allow outbound traffic to everywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
