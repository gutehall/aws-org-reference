variable "home_region" {
  type    = string
  default = "eu-north-1"
}

variable "alert_email" {
  type = string
}

variable "security_alert_email" {
  type    = string
  default = null
}

variable "break_glass_permission_set_arn" {
  type = string
}

variable "cloudtrail_log_group_name" {
  type = string
}

variable "security_account_id" {
  type = string
}

variable "name_prefix" {
  type    = string
  default = "aws-org-reference"
}

variable "tags" {
  type    = map(string)
  default = {}
}
