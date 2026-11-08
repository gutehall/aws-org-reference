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

resource "aws_dynamodb_table" "lock" {
  name         = "${var.name_prefix}-tflock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
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

resource "aws_iam_role" "terraform" {
  name               = "${var.name_prefix}-terraform"
  assume_role_policy = data.aws_iam_policy_document.terraform_assume.json

  tags = local.tags
}

# Broad enough for org landing applies from the management account.
# Narrow further per client if required; never use static access keys.
resource "aws_iam_role_policy_attachment" "terraform_admin" {
  role       = aws_iam_role.terraform.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
