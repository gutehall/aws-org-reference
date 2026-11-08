output "account_ids" {
  description = "Map of account name → id for every list entry."
  value = {
    for name, account in aws_organizations_account.this : name => account.id
  }
}

output "accounts" {
  description = "One object per list entry: name, id, role."
  value = [
    for name, account in aws_organizations_account.this : {
      name = name
      id   = account.id
      role = local.accounts_by_key[name].role
    }
  ]
}

output "organizational_unit_ids" {
  description = "Map of OU name → id."
  value = {
    for name, ou in aws_organizations_organizational_unit.this : name => ou.id
  }
}

output "member_scp_id" {
  description = "Service control policy id attached to member OUs."
  value       = aws_organizations_policy.member_deny.id
}

output "member_scp_json" {
  description = "SCP document for tests and the handoff (plain-language summary lives in docs/handoff.md)."
  value       = local.member_scp
}

output "log_archive_account_id" {
  description = "Account id for the log-archive role."
  value = one([
    for name, account in aws_organizations_account.this :
    account.id if local.accounts_by_key[name].role == "log-archive"
  ])
}

output "security_account_id" {
  description = "Account id for the security role."
  value = one([
    for name, account in aws_organizations_account.this :
    account.id if local.accounts_by_key[name].role == "security"
  ])
}

output "network_account_id" {
  description = "Account id for the network role, or null when absent."
  value = try(one([
    for name, account in aws_organizations_account.this :
    account.id if local.accounts_by_key[name].role == "network"
  ]), null)
}

output "workload_account_ids" {
  description = "Account ids for every workload role."
  value = [
    for name, account in aws_organizations_account.this :
    account.id if local.accounts_by_key[name].role == "workload"
  ]
}
