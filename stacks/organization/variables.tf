variable "home_region" {
  description = "Home region for the AWS provider."
  type        = string
  default     = "eu-north-1"
}

variable "accounts" {
  description = "Member account list from the private client tfvars."
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

  validation {
    condition = length([
      for a in var.accounts : a if a.role == "network"
    ]) <= 1
    error_message = "The account list may contain at most one account with role network."
  }
}

variable "region_allow_list" {
  description = "Regions permitted by SCP. See modules/organization for the global-service exception note."
  type        = list(string)
  default     = ["eu-north-1"]
}

variable "tags" {
  type    = map(string)
  default = {}
}
