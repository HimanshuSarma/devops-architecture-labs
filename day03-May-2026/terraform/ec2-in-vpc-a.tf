resource "aws_instance" "all_vpc_instances" {

  for_each = {
    for subnet in local.vpc_public_subnets : "${subnet.vpc_name}-pub-${subnet.index}" => subnet
  }

  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  key_name = "ec2"

  subnet_id = each.value.subnet_id

  vpc_security_group_ids = [aws_security_group.public_instance_sg[each.value.vpc_name].id]

  tags = {
    Name = "Instance-${each.key}"
  }
}