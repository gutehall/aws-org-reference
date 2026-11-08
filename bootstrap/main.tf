provider "aws" {
  region = var.home_region
}

data "aws_caller_identity" "current" {}

locals {
  tags = merge(
    {
      Project   = "aws-org-reference"
      Component = "bootstrap"
    },
    var.tags,
  )

  # token.actions.githubusercontent.com thumbprint used by AWS for GitHub OIDC.
  github_oidc_thumbprint = "6938fd4d98bab03faadb97b34396831e3780aea1"

  role_sub = var.github_branch == "" ? "repo:${var.github_repository}:*" : "repo:${var.github_repository}:ref:${var.github_branch}"
}

resource "aws_s3_bucket" "state" {
  bucket = "${var.name_prefix}-tfstate-${data.aws_caller_identity.current.account_id}"

  tags = local.tags
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    id     = "expire-old-versions"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

resource "aws_s3_bucket_policy" "state" {
  bucket = aws_s3_bucket.state.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.state.arn,
          "${aws_s3_bucket.state.arn}/*",
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
    ]
  })
}

resource "aws_dynamodb_table" "lock" {
  name         = "${var.name_prefix}-tflock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = local.tags
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [local.github_oidc_thumbprint]

  tags = local.tags
}

data "aws_iam_policy_document" "terraform_assume" {
  statement {
    sid     = "GitHubOIDC"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [local.role_sub]
    }
  }
}

# Permissions boundary: still allows landing applies, but blocks the worst footguns.
resource "aws_iam_policy" "terraform_boundary" {
  name = "${var.name_prefix}-terraform-boundary"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowLanding"
        Effect   = "Allow"
        Action   = "*"
        Resource = "*"
      },
      {
        Sid    = "DenyBoundaryEscapes"
        Effect = "Deny"
        Action = [
          "iam:CreateUser",
          "iam:CreateAccessKey",
          "iam:DeleteRolePermissionsBoundary",
          "iam:DeleteUserPermissionsBoundary",
          "organizations:LeaveOrganization",
          "account:CloseAccount",
        ]
        Resource = "*"
      },
    ]
  })

  tags = local.tags
}

resource "aws_iam_role" "terraform" {
  name                 = "${var.name_prefix}-terraform"
  assume_role_policy   = data.aws_iam_policy_document.terraform_assume.json
  permissions_boundary = aws_iam_policy.terraform_boundary.arn

  tags = local.tags
}

# Service-scoped landing permissions (not AdministratorAccess). Constrained
# further by the permissions boundary. Never use static access keys.
# Module CI must not assume this role.
resource "aws_iam_policy" "terraform_landing" {
  name = "${var.name_prefix}-terraform-landing"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "Organizations"
        Effect   = "Allow"
        Action   = ["organizations:*"]
        Resource = ["*"]
      },
      {
        Sid    = "IdentityCenter"
        Effect = "Allow"
        Action = [
          "sso:*",
          "sso-directory:*",
          "identitystore:*",
        ]
        Resource = ["*"]
      },
      {
        Sid      = "CloudTrail"
        Effect   = "Allow"
        Action   = ["cloudtrail:*"]
        Resource = ["*"]
      },
      {
        Sid      = "Config"
        Effect   = "Allow"
        Action   = ["config:*"]
        Resource = ["*"]
      },
      {
        Sid      = "GuardDuty"
        Effect   = "Allow"
        Action   = ["guardduty:*"]
        Resource = ["*"]
      },
      {
        Sid      = "Budgets"
        Effect   = "Allow"
        Action   = ["budgets:*"]
        Resource = ["*"]
      },
      {
        Sid    = "LogsAndMetrics"
        Effect = "Allow"
        Action = [
          "logs:*",
          "cloudwatch:*",
          "events:*",
          "sns:*",
        ]
        Resource = ["*"]
      },
      {
        Sid    = "StorageAndKeys"
        Effect = "Allow"
        Action = [
          "s3:*",
          "dynamodb:*",
          "kms:*",
        ]
        Resource = ["*"]
      },
      {
        Sid    = "Network"
        Effect = "Allow"
        Action = [
          "ec2:*",
          "ram:*",
        ]
        Resource = ["*"]
      },
      {
        Sid    = "IAMLanding"
        Effect = "Allow"
        Action = [
          "iam:Get*",
          "iam:List*",
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:UpdateRole",
          "iam:UpdateAssumeRolePolicy",
          "iam:TagRole",
          "iam:UntagRole",
          "iam:PassRole",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:GetRolePolicy",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:CreatePolicy",
          "iam:DeletePolicy",
          "iam:CreatePolicyVersion",
          "iam:DeletePolicyVersion",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:ListPolicyVersions",
          "iam:TagPolicy",
          "iam:UntagPolicy",
          "iam:CreateOpenIDConnectProvider",
          "iam:DeleteOpenIDConnectProvider",
          "iam:GetOpenIDConnectProvider",
          "iam:ListOpenIDConnectProviders",
          "iam:TagOpenIDConnectProvider",
          "iam:UntagOpenIDConnectProvider",
          "iam:UpdateOpenIDConnectProviderThumbprint",
        ]
        Resource = ["*"]
      },
      {
        Sid      = "AssumeMemberOrgAccessRole"
        Effect   = "Allow"
        Action   = ["sts:AssumeRole"]
        Resource = ["arn:aws:iam::*:role/OrganizationAccountAccessRole"]
      },
      {
        Sid      = "CallerIdentity"
        Effect   = "Allow"
        Action   = ["sts:GetCallerIdentity"]
        Resource = ["*"]
      },
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "terraform_landing" {
  role       = aws_iam_role.terraform.name
  policy_arn = aws_iam_policy.terraform_landing.arn
}
