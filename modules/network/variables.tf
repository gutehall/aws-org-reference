variable "home_region" {
  type    = string
  default = "eu-north-1"
}

variable "network_account_id" {
  description = "Required. Apply this module only when the account list has a network role."
  type        = string
}

variable "workload_account_ids" {
  description = "Workload accounts that receive the shared Transit Gateway via RAM and get private VPCs."
  type        = list(string)
  default     = []
}

variable "log_archive_account_id" {
  description = "Destination account for VPC flow logs."
  type        = string
}

variable "availability_zones" {
  description = "AZs for the egress VPC and workload private subnets."
  type        = list(string)
  default     = ["eu-north-1a", "eu-north-1b"]
}

variable "egress_vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "workload_vpc_cidrs" {
  description = "Map of workload account id → VPC CIDR. Required for each workload account that should get a VPC."
  type        = map(string)
  default     = {}
}

variable "name_prefix" {
  type    = string
  default = "aws-org-reference"
}

variable "tags" {
  type    = map(string)
  default = {}
}
