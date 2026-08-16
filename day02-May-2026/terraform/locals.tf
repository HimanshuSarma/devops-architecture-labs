locals {
  # Define everything in one place, or spread across files 
  # using different top-level keys
  vpc_a_configs = {
    common_tags = {
       name = var.vpc_a_name
    }
  }

  vpc_b_configs = {
    common_tags = {
       name = var.vpc_b_name
    }
  }
}