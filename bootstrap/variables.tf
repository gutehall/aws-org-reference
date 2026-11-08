variable "home_region" {
  description = "Region for the state backend and OIDC role. Defaults to eu-north-1."
  type        = string
  default     = "eu-north-1"
}

variable "name_prefix" {
  description = "Prefix for bootstrap resource names (bucket, lock table, role)."
  type        = string
  default     = "aws-org-reference"
}

variable "github_repository" {
  description = "GitHub repository allowed to assume the Terraform role via OIDC (owner/name). Not a hardcoded public repo."
  type        = string
}

variable "github_branch" {
  description = "Branch ref allowed to assume the role (e.g. refs/heads/main). Empty allows any ref in the repository."
  type        = string
  default     = "refs/heads/main"
}

variable "tags" {
  description = "Tags applied to bootstrap resources."
  type        = map(string)
  default     = {}
}
