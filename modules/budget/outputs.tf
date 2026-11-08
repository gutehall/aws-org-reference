output "budget_name" {
  value = aws_budgets_budget.monthly.name
}

output "threshold_usd" {
  value = var.budget_threshold_usd
}

output "notification_email" {
  value = local.notification_email
}

output "monthly_floor_note" {
  description = "Handoff text for the monthly floor."
  value       = "Monthly floor: GuardDuty + CloudTrail storage + accounts in the client list. Network module cost is separate when applied."
}
