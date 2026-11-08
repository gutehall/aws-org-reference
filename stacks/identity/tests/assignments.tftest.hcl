# Permission-set assignment shape with no real AWS credentials.

mock_provider "aws" {
  mock_data "aws_identitystore_group" {
    defaults = {
      group_id = "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
    }
  }
}

override_resource {
  target          = module.identity.aws_iam_role.break_glass
  override_during = plan
  values = {
    arn  = "arn:aws:iam::111111111111:role/BreakGlass"
    name = "BreakGlass"
    id   = "BreakGlass"
  }
}

variables {
  home_region            = "eu-north-1"
  identity_store_id      = "d-mock"
  instance_arn           = "arn:aws:sso:::instance/ssoins-mock"
  management_account_id  = "111111111111"
  log_archive_account_id = "222222222222"
  security_account_id    = "333333333333"
  network_account_id     = null
  workload_account_ids   = ["444444444444", "555555555555"]
  groups = {
    administrators      = "Administrators"
    security_auditors   = "SecurityAuditors"
    network_admins      = "NetworkAdmins"
    workload_developers = "WorkloadDevelopers"
    break_glass         = "BreakGlass"
  }
}

run "permission_sets_without_network" {
  command = plan

  assert {
    condition = alltrue([
      contains(keys(module.identity.permission_sets), "Administrator"),
      contains(keys(module.identity.permission_sets), "SecurityAuditor"),
      contains(keys(module.identity.permission_sets), "BreakGlass"),
      contains(keys(module.identity.permission_sets), "WorkloadDeveloper"),
      !contains(keys(module.identity.permission_sets), "NetworkAdmin"),
    ])
    error_message = "Expected Administrator, SecurityAuditor, BreakGlass, WorkloadDeveloper; no NetworkAdmin without a network account."
  }
}

run "break_glass_principals" {
  command = plan

  assert {
    condition     = module.identity.break_glass_role_arn == "arn:aws:iam::111111111111:role/BreakGlass"
    error_message = "BreakGlass IAM role ARN must be stable and known at plan."
  }

  assert {
    condition = module.identity.break_glass_allowed_principal_arns == [
      "arn:aws:iam::111111111111:role/BreakGlass",
      "arn:aws:iam::111111111111:role/aws-reserved/sso.amazonaws.com/*/AWSReservedSSO_BreakGlass_*",
    ]
    error_message = "Allowed principals must be IAM BreakGlass role + SSO pattern from identity."
  }
}

run "network_admin_when_network_present" {
  command = plan

  variables {
    network_account_id   = "666666666666"
    workload_account_ids = []
  }

  assert {
    condition     = contains(keys(module.identity.permission_sets), "NetworkAdmin")
    error_message = "NetworkAdmin permission set required when a network account id is set."
  }

  assert {
    condition     = !contains(keys(module.identity.permission_sets), "WorkloadDeveloper")
    error_message = "Zero workload accounts means zero WorkloadDeveloper assignments."
  }
}
