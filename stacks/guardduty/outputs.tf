output "findings_bucket_arn" {
  value = module.guardduty.findings_bucket_arn
}

output "findings_event_rule_name" {
  value = module.guardduty.findings_event_rule_name
}

output "detector_id" {
  value = module.guardduty.detector_id
}
