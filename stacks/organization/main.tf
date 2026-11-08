provider "aws" {
  region = var.home_region
}

module "organization" {
  source = "../../modules/organization"

  accounts          = var.accounts
  region_allow_list = var.region_allow_list
  tags              = var.tags
}
