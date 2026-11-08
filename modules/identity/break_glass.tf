# Stable break-glass principal shared by Identity Center, log-bucket delete
# exception, and the break-glass alarm. SSO sessions use AWSReservedSSO_BreakGlass_*;
# the IAM role covers API/CLI emergency use with a fixed ARN.

locals {
  break_glass_permission_set_name = aws_ssoadmin_permission_set.break_glass.name

  # Identity Center provisions roles under this path/name prefix in the target account.
  break_glass_sso_role_arn_pattern = "arn:aws:iam::${var.management_account_id}:role/aws-reserved/sso.amazonaws.com/*/AWSReservedSSO_${local.break_glass_permission_set_name}_*"

  break_glass_allowed_principal_arns = [
    aws_iam_role.break_glass.arn,
    local.break_glass_sso_role_arn_pattern,
  ]
}

resource "aws_iam_role" "break_glass" {
  name        = "BreakGlass"
  description = "Emergency break-glass role. Same principal model as the BreakGlass permission set for log-bucket delete exceptions."
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowManagementAccount"
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { AWS = "arn:aws:iam::${var.management_account_id}:root" }
    }]
  })
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "break_glass_admin" {
  role       = aws_iam_role.break_glass.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
