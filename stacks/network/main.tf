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

# Wire one workload_vpc module per workload account in the client stack,
# each with a provider that assumes into that account. See modules/network/README.md.
