# Runnable example root: validates module wiring with fake emails / placeholder ids.
# Copy terraform.tfvars.example → terraform.tfvars locally (gitignored) before apply.
# Real client values live under clients/, never here.

locals {
  log_archive = one([for a in var.accounts : a if a.role == "log-archive"])
  security    = one([for a in var.accounts : a if a.role == "security"])
  network     = try(one([for a in var.accounts : a if a.role == "network"]), null)
  workloads   = [for a in var.accounts : a if a.role == "workload"]
}

module "organization" {
  source = "../../modules/organization"

  accounts          = var.accounts
  region_allow_list = var.region_allow_list
}

# Later stacks consume org / identity / logging via remote state
# (remote_state.tf). Placeholders keep validate offline.

output "wiring_preview" {
  description = "How later stacks consume org + client inputs (fake ids until apply)."
  value = {
    home_region                        = var.home_region
    management_account_id              = var.management_account_id
    alert_email                        = var.alert_email
    budget_threshold_usd               = var.budget_threshold_usd
    groups                             = var.groups
    identity_store_id                  = var.identity_store_id
    identity_instance_arn              = var.identity_instance_arn
    log_archive_account_name           = local.log_archive.name
    security_account_name              = local.security.name
    network_account_name               = try(local.network.name, null)
    workload_account_names             = [for w in local.workloads : w.name]
    apply_network_stack                = local.network != null
    log_archive_account_id             = local.wiring.log_archive_account_id
    security_account_id                = local.wiring.security_account_id
    break_glass_allowed_principal_arns = local.wiring.break_glass_allowed_principal_arns
    flow_logs_bucket_arn               = local.wiring.flow_logs_bucket_arn
    use_remote_state                   = var.use_remote_state
  }
}

output "organization_accounts" {
  value = module.organization.accounts
}

output "member_scp_has_region_deny" {
  value = strcontains(module.organization.member_scp_json, "DenyOutsideRegionAllowList")
}
