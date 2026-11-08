locals {
  notification_email = coalesce(var.budget_email, var.alert_email)
}

resource "aws_budgets_budget" "monthly" {
  name              = var.budget_name
  budget_type       = "COST"
  limit_amount      = tostring(var.budget_threshold_usd)
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
  time_period_start = var.time_period_start

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [local.notification_email]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [local.notification_email]
  }

  tags = var.tags
}
