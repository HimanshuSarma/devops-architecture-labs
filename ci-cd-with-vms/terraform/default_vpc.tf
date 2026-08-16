# 1. Fetch the default VPC details
data "aws_vpc" "default" {
  default = true
}

# 2. Fetch all subnet IDs belonging to that default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}