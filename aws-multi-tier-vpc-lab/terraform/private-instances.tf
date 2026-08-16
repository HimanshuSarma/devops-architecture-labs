resource "aws_security_group" "private_instance_sg" {
  name        = "private_instance_sg"
  description = "Allow traffic only to the nodejs instance"
  vpc_id      = module.vpc.vpc_id

  # Inbound Rule: HTTP
  ingress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.internal_lb_sg.id, aws_security_group.public_instance_sg.id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_instance_sg.id]
  }

  # Outbound: Allow outbound traffic to everywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# 1. The Blueprint (Launch Template)
resource "aws_launch_template" "app_template" {
  name_prefix   = "app-template-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = "ec2"

  user_data = filebase64("${path.module}/private-instance-health-check-server-script.sh")

  network_interfaces {
    associate_public_ip_address = false # Internal instances
    security_groups             = [aws_security_group.private_instance_sg.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ASG-Instance"
    }
  }
}

# 2. The Factory (Auto Scaling Group)
resource "aws_autoscaling_group" "app_asg" {
  # This replaces the need for a "count" loop. 
  # It automatically distributes instances across these subnets.
  vpc_zone_identifier = module.vpc.private_subnets

  desired_capacity   = length(module.vpc.private_subnets) # Create 1 per subnet
  max_size           = length(module.vpc.private_subnets)
  min_size           = 1

  target_group_arns = [aws_lb_target_group.app_tg.arn] # Link to your Internal LB

  launch_template {
    id      = aws_launch_template.app_template.id
    version = "$Latest"
  }

  # This ensures the ASG waits for the LB target group to be healthy
  health_check_type         = "EC2"
  health_check_grace_period = 300
}

resource "aws_network_acl" "private_nacl" {
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # --- INBOUND RULES ---

  # Dynamic block for Port 8000
  dynamic "ingress" {
    for_each = var.vpc_private_subnets
    content {
      protocol   = "tcp"
      rule_no    = 100 + ingress.key # Generates 100, 101, 102...
      action     = "allow"
      cidr_block = ingress.value
      from_port  = 8000
      to_port    = 8000
    }
  }

  # Dynamic block for Port 3306
  dynamic "ingress" {
    for_each = var.vpc_private_subnets
    content {
      protocol   = "tcp"
      rule_no    = 200 + ingress.key # Generates 200, 201, 202...
      action     = "allow"
      cidr_block = ingress.value
      from_port  = 3306
      to_port    = 3306
    }
  }

  # Dynamic block for Port 3306
  dynamic "ingress" {
    for_each = var.vpc_private_subnets
    content {
      protocol   = "tcp"
      rule_no    = 300 + ingress.key # Generates 200, 201, 202...
      action     = "allow"
      cidr_block = ingress.value
      from_port  = 5432
      to_port    = 5432
    }
  }

  dynamic "ingress" {
    for_each = var.vpc_public_subnets
    content {
      protocol   = "tcp"
      rule_no    = 400 + ingress.key # Generates 200, 201, 202...
      action     = "allow"
      cidr_block = ingress.value
      from_port  = 80
      to_port    = 80
    }
  }

  # Standard rule for Ephemeral Ports
  dynamic "ingress" {
    for_each = var.vpc_public_subnets
    content {
      protocol   = "tcp"
      rule_no    = 500 + ingress.key # Generates 200, 201, 202...
      action     = "allow"
      cidr_block = ingress.value
      from_port  = 22
      to_port    = 22
    }
  }

  # You NEED this for return traffic (Statelessness)
  dynamic "ingress" {
    for_each = var.vpc_private_subnets
    content {
      protocol   = "tcp"
      rule_no    = 600 + ingress.key # Generates 200, 201, 202...
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = 1024
      to_port    = 65535
    }
  }

  # --- OUTBOUND RULES ---
  egress {
    protocol   = "all"
    rule_no    = 700
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "private-nacl"
  }
}