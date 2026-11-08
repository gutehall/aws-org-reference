variable "home_region" {
  type    = string
  default = "eu-north-1"
}

variable "identity_store_id" {
  type = string
}

variable "instance_arn" {
  type = string
}

variable "management_account_id" {
  type = string
}

variable "log_archive_account_id" {
  type = string
}

variable "security_account_id" {
  type = string
}

variable "network_account_id" {
  type    = string
  default = null
}

variable "workload_account_ids" {
  type    = list(string)
  default = []
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

variable "tags" {
  type    = map(string)
  default = {}
}
