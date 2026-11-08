variable "home_region" {
  type    = string
  default = "eu-north-1"
}

variable "security_account_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
