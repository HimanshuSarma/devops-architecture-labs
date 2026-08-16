terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket = "himanshutest-123"
    key = "terraform-ansible/terraform.tfstate"
    region = "us-east-1"

    dynamodb_table = "terraform-ansible"
  }
}

provider "aws" {
  region = var.aws_region
}