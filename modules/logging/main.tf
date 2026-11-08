locals {
  bucket_name      = "${var.name_prefix}-org-trail-${var.log_archive_account_id}"
  trail_bucket_arn = "arn:aws:s3:::${local.bucket_name}"
  tags = merge(
    {
      Project   = "aws-org-reference"
      Component = "logging"
    },
    var.tags,
  )

  # Pure HCL so tests can assert without mocking aws_iam_policy_document.
  trail_bucket_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AWSCloudTrailAclCheck"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:GetBucketAcl"
        Resource  = local.trail_bucket_arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = var.management_account_id
          }
        }
      },
      {
        Sid       = "AWSCloudTrailWrite"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource = [
          "${local.trail_bucket_arn}/AWSLogs/${var.management_account_id}/*",
          "${local.trail_bucket_arn}/AWSLogs/o-*/*",
        ]
        Condition = {
          StringEquals = {
            "s3:x-amz-acl"      = "bucket-owner-full-control"
            "aws:SourceAccount" = var.management_account_id
          }
        }
      },
      {
        Sid       = "AWSConfigWrite"
        Effect    = "Allow"
        Principal = { Service = "config.amazonaws.com" }
        Action    = ["s3:PutObject", "s3:GetBucketAcl"]
        Resource  = [local.trail_bucket_arn, "${local.trail_bucket_arn}/*"]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = [var.management_account_id, var.log_archive_account_id]
          }
        }
      },
      {
        Sid       = "DenyDeleteObjectExceptBreakGlass"
        Effect    = "Deny"
        Principal = "*"
        Action    = ["s3:DeleteObject", "s3:DeleteObjectVersion"]
        Resource  = "${local.trail_bucket_arn}/*"
        Condition = {
          ArnNotEquals = {
            "aws:PrincipalArn" = var.break_glass_role_arn
          }
        }
      },
    ]
  })
}

resource "aws_s3_bucket" "trail" {
  provider = aws.log_archive

  bucket = local.bucket_name
  tags   = local.tags
}

resource "aws_s3_bucket_versioning" "trail" {
  provider = aws.log_archive
  bucket   = aws_s3_bucket.trail.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "trail" {
  provider = aws.log_archive
  bucket   = aws_s3_bucket.trail.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "trail" {
  provider = aws.log_archive
  bucket   = aws_s3_bucket.trail.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "trail" {
  provider = aws.log_archive
  bucket   = aws_s3_bucket.trail.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_policy" "trail" {
  provider = aws.log_archive
  bucket   = aws_s3_bucket.trail.id
  policy   = local.trail_bucket_policy
}

resource "aws_cloudtrail" "organization" {
  name                          = "${var.name_prefix}-organization"
  s3_bucket_name                = aws_s3_bucket.trail.id
  include_global_service_events = true
  is_multi_region_trail         = true
  is_organization_trail         = true
  enable_log_file_validation    = true

  depends_on = [aws_s3_bucket_policy.trail]

  tags = local.tags
}

# Config delivery channel targets the same log-archive account/bucket.
# Recorders in member accounts are out of this stack; history lands here.
resource "aws_s3_object" "config_prefix" {
  provider = aws.log_archive

  bucket       = aws_s3_bucket.trail.id
  key          = "config/"
  content_type = "application/x-directory"
  content      = ""
}
