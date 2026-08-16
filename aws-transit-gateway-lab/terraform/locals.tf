locals {
  # Define everything in one place, or spread across files 
  # using different top-level keys

  vpc_map = {
    "vpc_a" = module.vpc_a
    "vpc_b" = module.vpc_b
    "vpc_c" = module.vpc_c
  }

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

  vpc_c_configs = {
    common_tags = {
      name = var.vpc_c_name
    }
  }

  # 2. Create a flat list of every public subnet across all VPCs
  vpc_public_subnets = flatten([
    for vpc_key, vpc_module in local.vpc_map : [
      for index, subnet_id in vpc_module.public_subnets : {
        vpc_name  = vpc_key
        subnet_id = subnet_id
        index     = index
      }
    ]
  ])
}
