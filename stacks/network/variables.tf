variable "home_region" {
  type    = string
  default = "eu-north-1"
}

variable "network_account_id" {
  description = "Required 12-digit network account id. Do not apply this stack without a network account in the client list."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.network_account_id))
    error_message = "network_account_id must be a 12-digit AWS account id. Skip this stack when the account list has no network role."
  }
}

variable "workload_account_ids" {
  type    = list(string)
  default = []
}

variable "log_archive_account_id" {
  type = string
}

variable "flow_logs_bucket_arn" {
  description = "Log-archive trail bucket ARN for VPC flow logs."
  type        = string
}

variable "workload_vpcs" {
  description = "Up to 4 workload accounts to receive a private VPC (account_id, name, cidr)."
  type = list(object({
    account_id = string
    name       = string
    cidr_block = string
  }))
  default = []

  validation {
    condition     = length(var.workload_vpcs) <= 4
    error_message = "This stack wires at most 4 workload VPCs (provider alias limit). Split additional accounts into another apply."
  }
}

variable "availability_zones" {
  type    = list(string)
  default = ["eu-north-1a", "eu-north-1b"]
}

variable "egress_vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "name_prefix" {
  type    = string
  default = "aws-org-reference"
}

variable "tags" {
  type    = map(string)
  default = {}
}
