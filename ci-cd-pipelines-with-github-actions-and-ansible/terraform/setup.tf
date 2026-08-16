terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket = "himanshutest-123-622047409214-us-east-1-an"
    key = "ci-cd-with-vms-and-asg/terraform.tfstate"
    region = "us-east-1"

    dynamodb_table = "ci-cd-with-vms-and-asg"
  }
}

provider "aws" {
  region = var.aws_region
}