resource "aws_sns_topic" "break_glass" {
  name = "${var.name_prefix}-break-glass"
  tags = var.tags
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.break_glass.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# CloudWatch metric filter on management CloudTrail events when BreakGlass is used.
# Event name pattern: Federate / AssumeRoleWithSAML style SSO events carrying the permission set.
resource "aws_cloudwatch_log_group" "break_glass" {
  name              = "/aws-org-reference/break-glass"
  retention_in_days = 90
  tags              = var.tags
}

resource "aws_cloudwatch_log_metric_filter" "break_glass" {
  name           = "${var.name_prefix}-break-glass-use"
  log_group_name = aws_cloudwatch_log_group.break_glass.name
  pattern        = "{ $.eventSource = \"sso.amazonaws.com\" && $.requestParameters.permissionSetArn = \"${var.break_glass_permission_set_arn}\" }"

  metric_transformation {
    name      = "BreakGlassPermissionSetUsed"
    namespace = "AwsOrgReference"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "break_glass" {
  alarm_name          = "${var.name_prefix}-break-glass-used"
  alarm_description   = "BreakGlass permission set was used. Visible to security; emailed to ${var.alert_email}."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "BreakGlassPermissionSetUsed"
  namespace           = "AwsOrgReference"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.break_glass.arn]
  tags                = merge(var.tags, { VisibleFromAccount = var.security_account_id })
}
