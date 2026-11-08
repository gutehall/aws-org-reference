variable "accounts" {
  description = "Member accounts to create. Exactly one log-archive and one security. Management is not included."
  type = list(object({
    name  = string
    email = string
    role  = string
    ou    = string
  }))

  validation {
    condition = length([
      for a in var.accounts : a if a.role == "log-archive"
    ]) == 1
    error_message = "The account list must contain exactly one account with role log-archive."
  }

  validation {
    condition = length([
      for a in var.accounts : a if a.role == "security"
    ]) == 1
    error_message = "The account list must contain exactly one account with role security."
  }

  validation {
    condition = alltrue([
      for a in var.accounts :
      contains(["log-archive", "security", "network", "workload"], a.role)
    ])
    error_message = "Each account role must be one of: log-archive, security, network, workload."
  }
}

variable "region_allow_list" {
  description = <<-EOT
    Regions permitted by SCP. Defaults to eu-north-1.
    Global-service exception: include us-east-1 in this list when AWS still
    requires it for a service you use. Do not scatter us-east-1 conditions
    elsewhere — keep the exception in this variable only.
  EOT
  type        = list(string)
  default     = ["eu-north-1"]
}

variable "tags" {
  description = "Tags for organization resources that support them."
  type        = map(string)
  default     = {}
}
