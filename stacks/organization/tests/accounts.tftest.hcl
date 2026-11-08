# Plans and validations with no real AWS credentials.

mock_provider "aws" {
  mock_data "aws_organizations_organization" {
    defaults = {
      roots = [
        {
          id   = "r-test"
          name = "Root"
          arn  = "arn:aws:organizations::111111111111:root/o-test/r-test"
        }
      ]
      id  = "o-test"
      arn = "arn:aws:organizations::111111111111:organization/o-test"
    }
  }
}

variables {
  home_region       = "eu-north-1"
  region_allow_list = ["eu-north-1"]
}

run "minimum_list_plans" {
  command = plan

  variables {
    accounts = [
      {
        name  = "log-archive"
        email = "aws-log-archive@example.com"
        role  = "log-archive"
        ou    = "Security"
      },
      {
        name  = "security"
        email = "aws-security@example.com"
        role  = "security"
        ou    = "Security"
      },
    ]
  }

  assert {
    condition     = length(module.organization.accounts) == 2
    error_message = "Minimum list should create exactly two member accounts."
  }
}

run "workload_list_plans" {
  command = plan

  variables {
    accounts = [
      {
        name  = "log-archive"
        email = "aws-log-archive@example.com"
        role  = "log-archive"
        ou    = "Security"
      },
      {
        name  = "security"
        email = "aws-security@example.com"
        role  = "security"
        ou    = "Security"
      },
      {
        name  = "workload-dev"
        email = "aws-workload-dev@example.com"
        role  = "workload"
        ou    = "Workloads"
      },
      {
        name  = "workload-prod"
        email = "aws-workload-prod@example.com"
        role  = "workload"
        ou    = "Workloads"
      },
    ]
  }

  assert {
    condition     = length(module.organization.workload_account_ids) == 2
    error_message = "Expected two workload accounts in the longer list."
  }
}

run "missing_log_archive_fails" {
  command         = plan
  expect_failures = [var.accounts]

  variables {
    accounts = [
      {
        name  = "security"
        email = "aws-security@example.com"
        role  = "security"
        ou    = "Security"
      },
    ]
  }
}

run "duplicate_security_fails" {
  command         = plan
  expect_failures = [var.accounts]

  variables {
    accounts = [
      {
        name  = "log-archive"
        email = "aws-log-archive@example.com"
        role  = "log-archive"
        ou    = "Security"
      },
      {
        name  = "security"
        email = "aws-security@example.com"
        role  = "security"
        ou    = "Security"
      },
      {
        name  = "security-2"
        email = "aws-security-2@example.com"
        role  = "security"
        ou    = "Security"
      },
    ]
  }
}

run "scp_contains_member_denies" {
  command = plan

  variables {
    accounts = [
      {
        name  = "log-archive"
        email = "aws-log-archive@example.com"
        role  = "log-archive"
        ou    = "Security"
      },
      {
        name  = "security"
        email = "aws-security@example.com"
        role  = "security"
        ou    = "Security"
      },
    ]
  }

  assert {
    condition = alltrue([
      strcontains(module.organization.member_scp_json, "DenyLeaveOrganization"),
      strcontains(module.organization.member_scp_json, "DenyDisableCloudTrail"),
      strcontains(module.organization.member_scp_json, "DenyDisableGuardDuty"),
      strcontains(module.organization.member_scp_json, "DenyOutsideRegionAllowList"),
      strcontains(module.organization.member_scp_json, "DenyCreateIamUsers"),
      strcontains(module.organization.member_scp_json, "iam:CreateUser"),
    ])
    error_message = "Member SCP must include leave-org, CloudTrail, GuardDuty, region, and IAM-user denies."
  }
}
