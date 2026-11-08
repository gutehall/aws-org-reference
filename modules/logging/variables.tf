variable "home_region" {
  type    = string
  default = "eu-north-1"
}

variable "log_archive_account_id" {
  description = "Account that holds the immutable evidence bucket."
  type        = string
}

variable "management_account_id" {
  description = "Management account that owns the organization trail."
  type        = string
}

variable "break_glass_allowed_principal_arns" {
  description = "Principals allowed to s3:DeleteObject on the log bucket (from identity module: IAM BreakGlass role + SSO pattern)."
  type        = list(string)

  validation {
    condition     = length(var.break_glass_allowed_principal_arns) > 0
    error_message = "At least one break-glass principal ARN or pattern is required."
  }
}

variable "flow_log_source_account_ids" {
  description = "Accounts allowed to deliver VPC flow logs to this bucket (workload + network)."
  type        = list(string)
  default     = []
}

variable "config_source_account_ids" {
  description = "Extra accounts allowed for Config delivery (e.g. all member accounts)."
  type        = list(string)
  default     = []
}

variable "name_prefix" {
  type    = string
  default = "aws-org-reference"
}

variable "tags" {
  type    = map(string)
  default = {}
}
