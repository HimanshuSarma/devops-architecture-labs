resource "aws_instance" "VPC-A-Instance" {

  count = length(module.vpc_a.public_subnets)

  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  key_name = "ec2"

  subnet_id = module.vpc_a.public_subnets[count.index]

  vpc_security_group_ids = [aws_security_group.public_instance_sg["vpc_a"].id]

  tags = {
    Name = "VPC-A-Instance"
  }
}