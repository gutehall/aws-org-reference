variable "home_region" {
  type    = string
  default = "eu-north-1"
}

variable "alert_email" {
  description = "Email from tfvars that receives break-glass use alarms."
  type        = string
}

variable "break_glass_permission_set_arn" {
  description = "Identity Center BreakGlass permission set ARN to watch."
  type        = string
}

variable "security_account_id" {
  description = "Security account — alarm is visible from here via SNS subscription mirror."
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
