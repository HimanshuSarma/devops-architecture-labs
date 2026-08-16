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

resource "aws_security_group" "public_instance_sg" {
  name        = "public_instance_sg"
  description = "Allow web traffic from the internet"
  vpc_id      = module.vpc.vpc_id

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

resource "aws_instance" "PublicInstance" {

  count = length(module.vpc.public_subnets)

  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  key_name = "ec2"

  subnet_id = module.vpc.public_subnets[count.index]

  vpc_security_group_ids = [aws_security_group.public_instance_sg.id]

  tags = {
    Name = "PublicInstance"
  }
}