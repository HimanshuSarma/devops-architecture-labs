data "aws_vpc" "default" {
  default = true
} 

data "aws_subnets" "public_subnet" {
  filter {
    name   = "subnet-arn"
    values = ["arn:aws:ec2:us-east-1:935743309473:subnet/subnet-05dd44622757402fa"]
  }
}

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
  name = "public_instance_sg"
  description = "Allow web traffic from the internet"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "public_instances" {

  count = 2

  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  key_name = "ec2"

  subnet_id = data.aws_subnets.public_subnet.ids[0]

  vpc_security_group_ids = [aws_security_group.public_instance_sg.id]

  tags = {
    # Using count.index to name them: Instance-0, Instance-1, etc.
    Name = "Backend-Server-${count.index}"
  }
}

