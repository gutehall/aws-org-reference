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

variable "break_glass_role_arn" {
  description = "Only principal allowed to s3:DeleteObject on the log bucket (break-glass)."
  type        = string
}

variable "name_prefix" {
  type    = string
  default = "aws-org-reference"
}

variable "tags" {
  type    = map(string)
  default = {}
}
