resource "aws_launch_template" "general_instance_template" {
  name   = "general-instance-template"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.medium"

  # Attach the Security Group created above
  vpc_security_group_ids = [aws_security_group.asg_sg.id]

  # SSH Key pair name already registered in your AWS Console
  key_name = "ec2"

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_instance" "bastion_host_node" {
  # Forces Terraform to wait for a specific version change if needed, 
  # or defaults to the latest version of the template automatically.
  launch_template {
    id      = aws_launch_template.general_instance_template.id
    version = "$Latest"
  }

  subnet_id = module.vpc.public_subnets[0]

  tags = {
    Name        = "bastion-host-node"
    Environment = "Dev/Prod"
  }
}