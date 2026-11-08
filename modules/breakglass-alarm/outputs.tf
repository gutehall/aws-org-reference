output "sns_topic_arn" {
  value = aws_sns_topic.break_glass.arn
}

output "alarm_name" {
  value = aws_cloudwatch_metric_alarm.break_glass.alarm_name
}

output "handoff_note" {
  value = "Break-glass use of permission set ${var.break_glass_permission_set_arn} alarms ${var.alert_email} and is tagged for visibility from security account ${var.security_account_id}."
}
