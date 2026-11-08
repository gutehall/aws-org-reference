provider "aws" {
  region = var.home_region
}

module "budget" {
  source = "../../modules/budget"

  budget_threshold_usd = var.budget_threshold_usd
  alert_email          = var.alert_email
  budget_email         = var.budget_email
  tags                 = var.tags
}
