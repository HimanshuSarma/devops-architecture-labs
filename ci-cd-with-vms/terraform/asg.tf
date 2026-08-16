data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# 1. Create a Security Group for the EC2 Instances
resource "aws_security_group" "asg_sg" {
  name        = "ansible-node-sg"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = data.aws_vpc.default.id

  # Allow inbound SSH (Required for your Ansible controller to connect)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # In prod, restrict this to your specific IP range
  }

  # Allow inbound HTTP for Nginx
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rules: Allow everything (Required to download apt/dnf updates)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "asg-sg"
  }
}

# 2. Define the Launch Template
resource "aws_launch_template" "asg_app_template" {
  name   = "asg-app-template"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  # Attach the Security Group created above
  vpc_security_group_ids = [aws_security_group.asg_sg.id]

  # SSH Key pair name already registered in your AWS Console
  key_name = "ec2"

  lifecycle {
    create_before_destroy = true
  }
}

# 3. Define the Auto Scaling Group
resource "aws_autoscaling_group" "app_asg" {
  name         = "app-asg"
  desired_capacity    = 2
  max_size            = 5
  min_size            = 1
  vpc_zone_identifier = data.aws_subnets.default.ids

  # Link the ASG to the Launch Template
  launch_template {
    id      = aws_launch_template.asg_app_template.id
    version = "$Latest" # Automatically uses the latest iteration of the template
  }

  tag {
    key                 = "Name"
    value               = "asg-app-node"
    propagate_at_launch = true
  }

  # Crucial for dynamic Ansible inventories
  tag {
    key                 = "Environment"
    value               = "Development"
    propagate_at_launch = true # Enforces that instances inherit this tag upon boot
  }

  tag {
    key                 = "Role"
    value               = "backend"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}