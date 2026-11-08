variable "home_region" {
  type    = string
  default = "eu-north-1"
}

variable "management_account_id" {
  description = "Fake id for validate/docs only — never a real client id in git."
  type        = string
  default     = "111111111111"
}

variable "accounts" {
  type = list(object({
    name  = string
    email = string
    role  = string
    ou    = string
  }))
}

variable "region_allow_list" {
  type    = list(string)
  default = ["eu-north-1"]
}

variable "groups" {
  type = object({
    administrators      = string
    security_auditors   = string
    network_admins      = string
    workload_developers = string
    break_glass         = string
  })
}

variable "budget_threshold_usd" {
  type = number
}

variable "alert_email" {
  type = string
}

variable "identity_store_id" {
  description = "Placeholder for wiring docs; identity stack needs a real value at apply."
  type        = string
  default     = "d-EXAMPLE"
}

variable "identity_instance_arn" {
  type    = string
  default = "arn:aws:sso:::instance/ssoins-EXAMPLE"
}
