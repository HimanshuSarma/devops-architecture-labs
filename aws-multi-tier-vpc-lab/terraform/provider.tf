terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket = "himanshutest-123"
    key = "1-mini-project/terraform.tfstate"
    region = "us-east-1"

    dynamodb_table = "1-mini-project"
  }
}

provider "aws" {
  region = var.aws_region
}