variable "home_region" {
  type    = string
  default = "eu-north-1"
}

variable "budget_threshold_usd" {
  type = number
}

variable "alert_email" {
  type = string
}

variable "budget_email" {
  type    = string
  default = null
}

variable "time_period_start" {
  description = "Budget start YYYY-MM-DD_HH:MM (UTC). Default: first day of current month."
  type        = string
  default     = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
