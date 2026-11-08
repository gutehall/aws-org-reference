# Deliver organization CloudTrail to CloudWatch Logs so break-glass (and other)
# detections can filter real events — not an orphan log group.

resource "aws_cloudwatch_log_group" "trail" {
  name              = "/aws-org-reference/${var.name_prefix}/cloudtrail"
  retention_in_days = 365
  tags              = local.tags
}

resource "aws_iam_role" "cloudtrail_cloudwatch" {
  name = "${var.name_prefix}-cloudtrail-logs"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "cloudtrail.amazonaws.com" }
    }]
  })
  tags = local.tags
}

resource "aws_iam_role_policy" "cloudtrail_cloudwatch" {
  name = "cloudtrail-cloudwatch"
  role = aws_iam_role.cloudtrail_cloudwatch.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "AWSCloudTrailCreateLogStream"
      Effect   = "Allow"
      Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
      Resource = "${aws_cloudwatch_log_group.trail.arn}:*"
    }]
  })
}
