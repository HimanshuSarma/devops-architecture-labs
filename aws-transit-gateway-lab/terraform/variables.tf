# Input Variables
# AWS Region
variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type = string
  default = "us-east-1"  
}

variable "vpc_a_name" {
  description = "VPC A name"
  type = string
  default = "vpc-a"
}

variable "vpc_a_cidr_block" {
  description = "VPC CIDR block"
  type = string
  default = "10.0.0.0/16"
}

variable "vpc_a_public_subnets" {
  description = "VPC A Public Subnets"
  type = list(string)
  # default = ["10.0.101.0/24", "10.0.102.0/24"]
  default = ["10.0.0.0/24"]
}

variable "vpc_a_private_subnets" {
  description = "VPC A Private Subnets"
  type = list(string)
  # default = ["10.0.101.0/24", "10.0.102.0/24"]
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "vpc_b_name" {
  description = "VPC B name"
  type = string
  default = "vpc-b"
}

variable "vpc_b_cidr_block" {
  description = "VPC B CIDR block"
  type = string
  default = "10.1.0.0/16"
}

variable "vpc_b_public_subnets" {
  description = "VPC Public Subnets"
  type = list(string)
  # default = ["10.0.101.0/24", "10.0.102.0/24"]
  default = ["10.1.0.0/24"]
}

variable "vpc_b_private_subnets" {
  description = "VPC Private Subnets"
  type = list(string)
  # default = ["10.0.101.0/24", "10.0.102.0/24"]
  default = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "vpc_c_name" {
  description = "VPC C name"
  type = string
  default = "vpc-c"
}

variable "vpc_c_cidr_block" {
  description = "VPC C CIDR block"
  type = string
  default = "10.2.0.0/16"
}

variable "vpc_c_public_subnets" {
  description = "VPC C Public Subnets"
  type = list(string)
  # default = ["10.0.101.0/24", "10.0.102.0/24"]
  default = ["10.2.0.0/24"]
}

variable "vpc_c_private_subnets" {
  description = "VPC C Private Subnets"
  type = list(string)
  # default = ["10.0.101.0/24", "10.0.102.0/24"]
  default = ["10.2.1.0/24", "10.2.2.0/24"]
}

variable "supernet_cidr_block" {
  description = "Supernet CIDR block that encompasses all VPCs"
  type = string
  default = "10.0.0.0/8"
}

variable "vpc_create_database_subnet_group" {
  description = "Should we have a db subnet group or not"
  type = bool
  default = false
}

variable "vpc_create_database_subnet_route_table" {
  description = "Should we have a db subnet route table or not"
  type = bool
  default = false
}

variable "vpc_enable_nat_gateway" {
  description = "Enable a NAT gateway or not"
  type = bool
  default = true
}

variable "vpc_single_nat_gateway" {
  description = "Do we need a single NAT?"
  type = bool
  default = true
}