locals {
  security_email = coalesce(var.security_alert_email, var.alert_email)
}

data "aws_caller_identity" "current" {}

resource "aws_sns_topic" "break_glass" {
  name              = "${var.name_prefix}-break-glass"
  kms_master_key_id = "alias/aws/sns"
  tags = merge(var.tags, {
    SecurityAccountId = var.security_account_id
  })
}

resource "aws_sns_topic_policy" "break_glass" {
  arn = aws_sns_topic.break_glass.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowOwner"
        Effect    = "Allow"
        Principal = { AWS = "*" }
        Action    = ["sns:Subscribe", "sns:Receive", "sns:Publish"]
        Resource  = aws_sns_topic.break_glass.arn
        Condition = {
          StringEquals = {
            "AWS:SourceOwner" = data.aws_caller_identity.current.account_id
          }
        }
      },
      {
        Sid       = "AllowSecurityAccountSubscribe"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${var.security_account_id}:root" }
        Action    = ["sns:Subscribe", "sns:Receive", "sns:ListSubscriptionsByTopic"]
        Resource  = aws_sns_topic.break_glass.arn
      },
      {
        Sid       = "AllowEventBridgePublish"
        Effect    = "Allow"
        Principal = { Service = "events.amazonaws.com" }
        Action    = "sns:Publish"
        Resource  = aws_sns_topic.break_glass.arn
      },
    ]
  })
}

resource "aws_sns_topic_subscription" "alert_email" {
  topic_arn = aws_sns_topic.break_glass.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_sns_topic_subscription" "security_email" {
  count = local.security_email == var.alert_email ? 0 : 1

  topic_arn = aws_sns_topic.break_glass.arn
  protocol  = "email"
  endpoint  = local.security_email
}

# Primary detection: EventBridge on CloudTrail Identity Center / sign-in events.
resource "aws_cloudwatch_event_rule" "break_glass" {
  name        = "${var.name_prefix}-break-glass-used"
  description = "Fires when the BreakGlass permission set is used."

  event_pattern = jsonencode({
    source      = ["aws.sso", "aws.signin"]
    detail-type = ["AWS API Call via CloudTrail"]
    detail = {
      eventSource = ["sso.amazonaws.com", "signin.amazonaws.com"]
      requestParameters = {
        permissionSetArn = [var.break_glass_permission_set_arn]
      }
    }
  })

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "break_glass_sns" {
  rule = aws_cloudwatch_event_rule.break_glass.name
  arn  = aws_sns_topic.break_glass.arn
}

# Secondary: metric filter on the organization trail log group from the logging stack.
resource "aws_cloudwatch_log_metric_filter" "break_glass" {
  name           = "${var.name_prefix}-break-glass-use"
  log_group_name = var.cloudtrail_log_group_name
  pattern        = "{ ($.eventSource = \"sso.amazonaws.com\" || $.eventSource = \"signin.amazonaws.com\") && ($.requestParameters.permissionSetArn = \"${var.break_glass_permission_set_arn}\" || $.additionalEventData.permissionSetArn = \"${var.break_glass_permission_set_arn}\") }"

  metric_transformation {
    name      = "BreakGlassPermissionSetUsed"
    namespace = "AwsOrgReference"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "break_glass" {
  alarm_name          = "${var.name_prefix}-break-glass-used"
  alarm_description   = "BreakGlass permission set was used. Notifies ${var.alert_email}. Security account ${var.security_account_id} can subscribe to ${aws_sns_topic.break_glass.arn}. Confirm SNS email subscriptions after apply."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "BreakGlassPermissionSetUsed"
  namespace           = "AwsOrgReference"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.break_glass.arn]
  tags = merge(var.tags, {
    SecurityAccountId = var.security_account_id
  })
}
