provider "aws" {
  region = var.home_region
}

module "identity" {
  source = "../../modules/identity"

  home_region            = var.home_region
  identity_store_id      = var.identity_store_id
  instance_arn           = var.instance_arn
  management_account_id  = var.management_account_id
  log_archive_account_id = var.log_archive_account_id
  security_account_id    = var.security_account_id
  network_account_id     = var.network_account_id
  workload_account_ids   = var.workload_account_ids
  groups                 = var.groups
  tags                   = var.tags
}
