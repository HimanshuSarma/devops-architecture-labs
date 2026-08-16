terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket = "himanshutest-123"
    key = "vpc-peering/terraform.tfstate"
    region = "us-east-1"

    dynamodb_table = "transit-gateway"
  }
}

provider "aws" {
  region = var.aws_region
}