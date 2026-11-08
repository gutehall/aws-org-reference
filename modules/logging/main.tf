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

  flow_log_statements = length(var.flow_log_source_account_ids) == 0 ? [] : [
    {
      Sid       = "AWSLogDeliveryWrite"
      Effect    = "Allow"
      Principal = { Service = "delivery.logs.amazonaws.com" }
      Action    = ["s3:PutObject", "s3:GetBucketAcl"]
      Resource  = [local.trail_bucket_arn, "${local.trail_bucket_arn}/*"]
      Condition = {
        StringEquals = {
          "aws:SourceAccount" = var.flow_log_source_account_ids
          "s3:x-amz-acl"      = "bucket-owner-full-control"
        }
      }
    },
  ]

  # Pure HCL so tests can assert without mocking aws_iam_policy_document.
  trail_bucket_policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
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
          Action    = ["s3:PutObject", "s3:GetBucketAcl", "s3:ListBucket"]
          Resource  = [local.trail_bucket_arn, "${local.trail_bucket_arn}/*"]
          Condition = {
            StringEquals = {
              "aws:SourceAccount" = concat(
                [var.management_account_id, var.log_archive_account_id],
                var.config_source_account_ids,
              )
            }
          }
        },
      ],
      local.flow_log_statements,
      [
        {
          Sid       = "DenyDeleteObjectExceptBreakGlass"
          Effect    = "Deny"
          Principal = "*"
          Action    = ["s3:DeleteObject", "s3:DeleteObjectVersion"]
          Resource  = "${local.trail_bucket_arn}/*"
          # Deny unless the caller matches one of the identity-module principals
          # (stable IAM BreakGlass role or AWSReservedSSO_BreakGlass_* pattern).
          Condition = {
            ArnNotLike = {
              "aws:PrincipalArn" = var.break_glass_allowed_principal_arns
            }
          }
        },
        {
          Sid       = "DenyInsecureTransport"
          Effect    = "Deny"
          Principal = "*"
          Action    = "s3:*"
          Resource  = [local.trail_bucket_arn, "${local.trail_bucket_arn}/*"]
          Condition = {
            Bool = {
              "aws:SecureTransport" = "false"
            }
          }
        },
      ],
    )
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
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "trail" {
  provider = aws.log_archive
  bucket   = aws_s3_bucket.trail.id

  rule {
    id     = "retain-evidence"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    transition {
      days          = 90
      storage_class = "STANDARD_IA"
    }

    noncurrent_version_expiration {
      noncurrent_days = 365
    }
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
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.trail.arn}:*"
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_cloudwatch.arn

  depends_on = [
    aws_s3_bucket_policy.trail,
    aws_iam_role_policy.cloudtrail_cloudwatch,
  ]

  tags = local.tags
}
