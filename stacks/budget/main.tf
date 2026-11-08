provider "aws" {
  region = var.home_region
}

module "budget" {
  source = "../../modules/budget"

  budget_threshold_usd = var.budget_threshold_usd
  alert_email          = var.alert_email
  budget_email         = var.budget_email
  # Stable past start avoids timestamp() plan churn; AWS Budgets accepts it.
  time_period_start = coalesce(var.time_period_start, "2020-01-01_00:00")
  tags              = var.tags
}
