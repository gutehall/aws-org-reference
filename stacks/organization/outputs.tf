output "accounts" {
  value = module.organization.accounts
}

output "account_ids" {
  value = module.organization.account_ids
}

output "member_scp_json" {
  value = module.organization.member_scp_json
}

output "log_archive_account_id" {
  value = module.organization.log_archive_account_id
}

output "security_account_id" {
  value = module.organization.security_account_id
}

output "network_account_id" {
  value = module.organization.network_account_id
}

output "workload_account_ids" {
  value = module.organization.workload_account_ids
}
