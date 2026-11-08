output "delegated_admin_account_id" {
  description = "GuardDuty delegated administrator account id."
  value       = var.security_account_id
}

output "detector_id" {
  value = aws_guardduty_detector.security.id
}
