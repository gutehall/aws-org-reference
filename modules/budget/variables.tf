variable "budget_threshold_usd" {
  description = "Monthly spend threshold from the client tfvars."
  type        = number
}

variable "alert_email" {
  description = "Break-glass / default alert email from tfvars."
  type        = string
}

variable "budget_email" {
  description = "Optional override for budget notifications. Defaults to alert_email."
  type        = string
  default     = null
}

variable "budget_name" {
  type    = string
  default = "aws-org-reference-monthly"
}

variable "tags" {
  type    = map(string)
  default = {}
}
