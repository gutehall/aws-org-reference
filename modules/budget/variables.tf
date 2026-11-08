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

variable "time_period_start" {
  description = "Budget start (AWS Budgets format YYYY-MM-DD_HH:MM). Defaults to the first of the current UTC month at apply time via the stack."
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
