output "delegated_admin_account_id" {
  description = "GuardDuty delegated administrator account id."
  value       = var.security_account_id
}

output "detector_id" {
  value = aws_guardduty_detector.security.id
}

output "findings_bucket_arn" {
  description = "S3 bucket in the security account where GuardDuty findings are exported."
  value       = aws_s3_bucket.findings.arn
}

output "findings_bucket_name" {
  value = aws_s3_bucket.findings.id
}

output "findings_event_rule_name" {
  description = "EventBridge rule on GuardDuty findings in the security account."
  value       = aws_cloudwatch_event_rule.findings.name
}
