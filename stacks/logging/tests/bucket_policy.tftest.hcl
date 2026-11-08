# Bucket policy shape with no real AWS credentials.

mock_provider "aws" {}

mock_provider "aws" {
  alias = "log_archive"
}

variables {
  home_region             = "eu-north-1"
  log_archive_account_id  = "222222222222"
  management_account_id   = "111111111111"
  break_glass_role_arn    = "arn:aws:iam::111111111111:role/BreakGlass"
  name_prefix             = "example"
  assume_log_archive_role = false
}

run "deny_delete_except_break_glass" {
  command = plan

  assert {
    condition = alltrue([
      strcontains(module.logging.trail_bucket_policy_json, "DenyDeleteObjectExceptBreakGlass"),
      strcontains(module.logging.trail_bucket_policy_json, "s3:DeleteObject"),
      strcontains(module.logging.trail_bucket_policy_json, "arn:aws:iam::111111111111:role/BreakGlass"),
      strcontains(module.logging.trail_bucket_policy_json, "ArnNotEquals"),
    ])
    error_message = "Log bucket policy must deny DeleteObject for everyone except the break-glass role."
  }
}
