provider "aws" {
  region = var.home_region
}

provider "aws" {
  alias  = "network"
  region = var.home_region

  assume_role {
    role_arn = "arn:aws:iam::${var.network_account_id}:role/OrganizationAccountAccessRole"
  }
}

# Per-workload assume-role providers (Terraform cannot for_each providers).
provider "aws" {
  alias  = "workload_0"
  region = var.home_region

  dynamic "assume_role" {
    for_each = length(var.workload_vpcs) > 0 ? [var.workload_vpcs[0]] : []
    content {
      role_arn = "arn:aws:iam::${assume_role.value.account_id}:role/OrganizationAccountAccessRole"
    }
  }
}

provider "aws" {
  alias  = "workload_1"
  region = var.home_region

  dynamic "assume_role" {
    for_each = length(var.workload_vpcs) > 1 ? [var.workload_vpcs[1]] : []
    content {
      role_arn = "arn:aws:iam::${assume_role.value.account_id}:role/OrganizationAccountAccessRole"
    }
  }
}

provider "aws" {
  alias  = "workload_2"
  region = var.home_region

  dynamic "assume_role" {
    for_each = length(var.workload_vpcs) > 2 ? [var.workload_vpcs[2]] : []
    content {
      role_arn = "arn:aws:iam::${assume_role.value.account_id}:role/OrganizationAccountAccessRole"
    }
  }
}

provider "aws" {
  alias  = "workload_3"
  region = var.home_region

  dynamic "assume_role" {
    for_each = length(var.workload_vpcs) > 3 ? [var.workload_vpcs[3]] : []
    content {
      role_arn = "arn:aws:iam::${assume_role.value.account_id}:role/OrganizationAccountAccessRole"
    }
  }
}

module "network" {
  source = "../../modules/network"

  providers = {
    aws         = aws
    aws.network = aws.network
  }

  home_region            = var.home_region
  network_account_id     = var.network_account_id
  workload_account_ids   = var.workload_account_ids
  log_archive_account_id = var.log_archive_account_id
  availability_zones     = var.availability_zones
  egress_vpc_cidr        = var.egress_vpc_cidr
  name_prefix            = var.name_prefix
  tags                   = var.tags
}

module "workload_vpc_0" {
  count  = length(var.workload_vpcs) > 0 ? 1 : 0
  source = "../../modules/network/workload_vpc"

  providers = {
    aws = aws.workload_0
  }

  name                 = var.workload_vpcs[0].name
  cidr_block           = var.workload_vpcs[0].cidr_block
  availability_zones   = var.availability_zones
  transit_gateway_id   = module.network.transit_gateway_id
  flow_logs_bucket_arn = var.flow_logs_bucket_arn
  tags                 = var.tags
}

module "workload_vpc_1" {
  count  = length(var.workload_vpcs) > 1 ? 1 : 0
  source = "../../modules/network/workload_vpc"

  providers = {
    aws = aws.workload_1
  }

  name                 = var.workload_vpcs[1].name
  cidr_block           = var.workload_vpcs[1].cidr_block
  availability_zones   = var.availability_zones
  transit_gateway_id   = module.network.transit_gateway_id
  flow_logs_bucket_arn = var.flow_logs_bucket_arn
  tags                 = var.tags
}

module "workload_vpc_2" {
  count  = length(var.workload_vpcs) > 2 ? 1 : 0
  source = "../../modules/network/workload_vpc"

  providers = {
    aws = aws.workload_2
  }

  name                 = var.workload_vpcs[2].name
  cidr_block           = var.workload_vpcs[2].cidr_block
  availability_zones   = var.availability_zones
  transit_gateway_id   = module.network.transit_gateway_id
  flow_logs_bucket_arn = var.flow_logs_bucket_arn
  tags                 = var.tags
}

module "workload_vpc_3" {
  count  = length(var.workload_vpcs) > 3 ? 1 : 0
  source = "../../modules/network/workload_vpc"

  providers = {
    aws = aws.workload_3
  }

  name                 = var.workload_vpcs[3].name
  cidr_block           = var.workload_vpcs[3].cidr_block
  availability_zones   = var.availability_zones
  transit_gateway_id   = module.network.transit_gateway_id
  flow_logs_bucket_arn = var.flow_logs_bucket_arn
  tags                 = var.tags
}
