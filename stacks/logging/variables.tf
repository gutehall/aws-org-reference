variable "home_region" {
  type    = string
  default = "eu-north-1"
}

variable "log_archive_account_id" {
  type = string
}

variable "management_account_id" {
  type = string
}

variable "break_glass_role_arn" {
  type = string
}

variable "name_prefix" {
  type    = string
  default = "aws-org-reference"
}

variable "assume_log_archive_role" {
  description = "When true, the log_archive provider assumes OrganizationAccountAccessRole. Disable for local tests."
  type        = bool
  default     = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
