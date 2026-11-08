output "sns_topic_arn" {
  value = aws_sns_topic.break_glass.arn
}

output "alarm_name" {
  value = aws_cloudwatch_metric_alarm.break_glass.alarm_name
}

output "event_rule_name" {
  value = aws_cloudwatch_event_rule.break_glass.name
}

output "handoff_note" {
  value = "Break-glass use of permission set ${var.break_glass_permission_set_arn} notifies ${var.alert_email} via SNS ${aws_sns_topic.break_glass.arn} (confirm email subscription). Security account ${var.security_account_id} may subscribe to the same topic. Trail also lands in CloudWatch Logs group ${var.cloudtrail_log_group_name}."
}
