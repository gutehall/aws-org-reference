# Supported wiring path after organization (and later stacks) have state.
# Values below are placeholders so `terraform validate` works without AWS.
# After bootstrap, replace bucket / table / region from bootstrap outputs
# (see also stacks/remote_state.tf.example).

variable "remote_state_bucket" {
  description = "S3 state bucket from bootstrap. Placeholder is fine for validate."
  type        = string
  default     = "aws-org-reference-tfstate-111111111111"
}

variable "remote_state_region" {
  type    = string
  default = "eu-north-1"
}

variable "use_remote_state" {
  description = "Set true in a real client root after organization apply. False keeps validate offline."
  type        = bool
  default     = false
}

data "terraform_remote_state" "organization" {
  count   = var.use_remote_state ? 1 : 0
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket
    key    = "organization/terraform.tfstate"
    region = var.remote_state_region
  }
}

data "terraform_remote_state" "identity" {
  count   = var.use_remote_state ? 1 : 0
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket
    key    = "identity/terraform.tfstate"
    region = var.remote_state_region
  }
}

data "terraform_remote_state" "logging" {
  count   = var.use_remote_state ? 1 : 0
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket
    key    = "logging/terraform.tfstate"
    region = var.remote_state_region
  }
}

locals {
  # When remote state is off, placeholders show the shape of later-stack inputs.
  org_rs      = try(data.terraform_remote_state.organization[0].outputs, {})
  identity_rs = try(data.terraform_remote_state.identity[0].outputs, {})
  logging_rs  = try(data.terraform_remote_state.logging[0].outputs, {})

  wiring = {
    log_archive_account_id = try(
      local.org_rs.log_archive_account_id,
      "111111111111",
    )
    security_account_id = try(
      local.org_rs.security_account_id,
      "222222222222",
    )
    break_glass_allowed_principal_arns = try(
      local.identity_rs.break_glass_allowed_principal_arns,
      [
        "arn:aws:iam::111111111111:role/BreakGlass",
        "arn:aws:iam::111111111111:role/aws-reserved/sso.amazonaws.com/*/AWSReservedSSO_BreakGlass_*",
      ],
    )
    flow_logs_bucket_arn = try(
      local.logging_rs.trail_bucket_arn,
      "arn:aws:s3:::example-org-trail",
    )
  }
}
