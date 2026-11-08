variable "security_account_id" {
  description = "Delegated GuardDuty administrator (security role)."
  type        = string
}

variable "home_region" {
  type    = string
  default = "eu-north-1"
}

variable "tags" {
  type    = map(string)
  default = {}
}
