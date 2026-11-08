variable "home_region" {
  description = "Identity Center home region (must already be enabled)."
  type        = string
  default     = "eu-north-1"
}

variable "identity_store_id" {
  description = "Identity Store id for the enabled Identity Center instance."
  type        = string
}

variable "instance_arn" {
  description = "ARN of the Identity Center instance."
  type        = string
}

variable "management_account_id" {
  description = "Management account id (Administrator and BreakGlass only)."
  type        = string
}

variable "log_archive_account_id" {
  description = "log-archive account id."
  type        = string
}

variable "security_account_id" {
  description = "security account id."
  type        = string
}

variable "network_account_id" {
  description = "network account id, or null when the list has no network account."
  type        = string
  default     = null
}

variable "workload_account_ids" {
  description = "Account ids with role workload. Empty list means no WorkloadDeveloper assignments."
  type        = list(string)
  default     = []
}

variable "groups" {
  description = "Identity Center group display names from the client tfvars."
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
