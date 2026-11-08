variable "home_region" {
  type    = string
  default = "eu-north-1"
}

variable "network_account_id" {
  type = string
}

variable "workload_account_ids" {
  type    = list(string)
  default = []
}

variable "log_archive_account_id" {
  type = string
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
