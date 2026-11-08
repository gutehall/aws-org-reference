variable "home_region" {
  type    = string
  default = "eu-north-1"
}

variable "alert_email" {
  description = "Email from tfvars that receives break-glass use alarms. Confirm the SNS subscription after apply."
  type        = string
}

variable "security_alert_email" {
  description = "Optional second email (security team). Defaults to alert_email."
  type        = string
  default     = null
}

variable "break_glass_permission_set_arn" {
  description = "Identity Center BreakGlass permission set ARN to watch."
  type        = string
}

variable "cloudtrail_log_group_name" {
  description = "Organization trail CloudWatch Logs group from the logging stack."
  type        = string
}

variable "security_account_id" {
  description = "Security account — may subscribe to the SNS topic."
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
