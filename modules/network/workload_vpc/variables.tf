variable "name" {
  description = "Name prefix for VPC resources in this workload account."
  type        = string
}

variable "cidr_block" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "transit_gateway_id" {
  description = "Shared TGW id (accepted via RAM in this account)."
  type        = string
}

variable "flow_logs_bucket_arn" {
  description = "Log-archive bucket ARN for VPC flow logs."
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
