# Findings export lands in the security account (S3 publishing destination).

locals {
  findings_bucket_name = "${var.name_prefix}-guardduty-findings-${var.security_account_id}"
}

resource "aws_kms_key" "findings" {
  provider = aws.security

  description             = "GuardDuty findings export"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags                    = var.tags

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnableRoot"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${var.security_account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Sid       = "AllowGuardDuty"
        Effect    = "Allow"
        Principal = { Service = "guardduty.amazonaws.com" }
        Action = [
          "kms:GenerateDataKey",
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:CreateGrant",
          "kms:DescribeKey",
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = var.security_account_id
          }
        }
      },
    ]
  })
}

resource "aws_kms_alias" "findings" {
  provider = aws.security

  name          = "alias/${var.name_prefix}-guardduty-findings"
  target_key_id = aws_kms_key.findings.key_id
}

resource "aws_s3_bucket" "findings" {
  provider = aws.security

  bucket = local.findings_bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_public_access_block" "findings" {
  provider = aws.security
  bucket   = aws_s3_bucket.findings.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "findings" {
  provider = aws.security
  bucket   = aws_s3_bucket.findings.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "findings" {
  provider = aws.security
  bucket   = aws_s3_bucket.findings.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.findings.arn
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "findings" {
  provider = aws.security
  bucket   = aws_s3_bucket.findings.id

  rule {
    id     = "retain-findings"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    transition {
      days          = 90
      storage_class = "STANDARD_IA"
    }

    expiration {
      days = 365
    }
  }
}

resource "aws_s3_bucket_policy" "findings" {
  provider = aws.security
  bucket   = aws_s3_bucket.findings.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowGuardDutyPut"
        Effect    = "Allow"
        Principal = { Service = "guardduty.amazonaws.com" }
        Action    = ["s3:PutObject", "s3:GetBucketLocation", "s3:ListBucket"]
        Resource = [
          aws_s3_bucket.findings.arn,
          "${aws_s3_bucket.findings.arn}/*",
        ]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = var.security_account_id
          }
        }
      },
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.findings.arn,
          "${aws_s3_bucket.findings.arn}/*",
        ]
        Condition = {
          Bool = { "aws:SecureTransport" = "false" }
        }
      },
    ]
  })
}

resource "aws_guardduty_publishing_destination" "s3" {
  provider = aws.security

  detector_id     = aws_guardduty_detector.security.id
  destination_arn = aws_s3_bucket.findings.arn
  kms_key_arn     = aws_kms_key.findings.arn

  depends_on = [aws_s3_bucket_policy.findings]
}

# Also fan findings into EventBridge in the security account for SIEM hooks.
resource "aws_cloudwatch_event_rule" "findings" {
  provider = aws.security

  name        = "${var.name_prefix}-guardduty-findings"
  description = "GuardDuty findings in the security account"

  event_pattern = jsonencode({
    source      = ["aws.guardduty"]
    detail-type = ["GuardDuty Finding"]
  })

  tags = var.tags
}
