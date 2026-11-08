data "aws_identitystore_group" "administrators" {
  identity_store_id = var.identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = var.groups.administrators
    }
  }
}

data "aws_identitystore_group" "security_auditors" {
  identity_store_id = var.identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = var.groups.security_auditors
    }
  }
}

data "aws_identitystore_group" "network_admins" {
  count = var.network_account_id == null ? 0 : 1

  identity_store_id = var.identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = var.groups.network_admins
    }
  }
}

data "aws_identitystore_group" "workload_developers" {
  count = length(var.workload_account_ids) == 0 ? 0 : 1

  identity_store_id = var.identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = var.groups.workload_developers
    }
  }
}

data "aws_identitystore_group" "break_glass" {
  identity_store_id = var.identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = var.groups.break_glass
    }
  }
}

resource "aws_ssoadmin_permission_set" "administrator" {
  name             = "Administrator"
  description      = "Full admin on the management account only."
  instance_arn     = var.instance_arn
  session_duration = "PT4H"
  tags             = var.tags
}

resource "aws_ssoadmin_managed_policy_attachment" "administrator" {
  instance_arn       = var.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.administrator.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_ssoadmin_account_assignment" "administrator" {
  instance_arn       = var.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.administrator.arn

  principal_id   = data.aws_identitystore_group.administrators.group_id
  principal_type = "GROUP"

  target_id   = var.management_account_id
  target_type = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_permission_set" "security_auditor" {
  name             = "SecurityAuditor"
  description      = "Read-only security audit on log-archive and security accounts."
  instance_arn     = var.instance_arn
  session_duration = "PT4H"
  tags             = var.tags
}

resource "aws_ssoadmin_managed_policy_attachment" "security_auditor" {
  instance_arn       = var.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.security_auditor.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

resource "aws_ssoadmin_account_assignment" "security_auditor" {
  for_each = toset([var.log_archive_account_id, var.security_account_id])

  instance_arn       = var.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.security_auditor.arn

  principal_id   = data.aws_identitystore_group.security_auditors.group_id
  principal_type = "GROUP"

  target_id   = each.value
  target_type = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_permission_set" "network_admin" {
  count = var.network_account_id == null ? 0 : 1

  name             = "NetworkAdmin"
  description      = "Network administration on the network account only."
  instance_arn     = var.instance_arn
  session_duration = "PT4H"
  tags             = var.tags
}

resource "aws_ssoadmin_managed_policy_attachment" "network_admin" {
  count = var.network_account_id == null ? 0 : 1

  instance_arn       = var.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.network_admin[0].arn
  managed_policy_arn = "arn:aws:iam::aws:policy/job-function/NetworkAdministrator"
}

resource "aws_ssoadmin_account_assignment" "network_admin" {
  count = var.network_account_id == null ? 0 : 1

  instance_arn       = var.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.network_admin[0].arn

  principal_id   = data.aws_identitystore_group.network_admins[0].group_id
  principal_type = "GROUP"

  target_id   = var.network_account_id
  target_type = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_permission_set" "workload_developer" {
  count = length(var.workload_account_ids) == 0 ? 0 : 1

  name             = "WorkloadDeveloper"
  description      = "Workload development without AdministratorAccess, IAM changes, or network changes."
  instance_arn     = var.instance_arn
  session_duration = "PT8H"
  tags             = var.tags
}

# PowerUserAccess excludes IAM; explicit denies reinforce no IAM/network admin.
resource "aws_ssoadmin_managed_policy_attachment" "workload_developer_poweruser" {
  count = length(var.workload_account_ids) == 0 ? 0 : 1

  instance_arn       = var.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.workload_developer[0].arn
  managed_policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

resource "aws_ssoadmin_permission_set_inline_policy" "workload_developer_deny" {
  count = length(var.workload_account_ids) == 0 ? 0 : 1

  instance_arn       = var.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.workload_developer[0].arn

  inline_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyIamChanges"
        Effect = "Deny"
        Action = [
          "iam:*",
          "organizations:*",
          "account:*",
        ]
        Resource = "*"
      },
      {
        Sid    = "DenyNetworkChanges"
        Effect = "Deny"
        Action = [
          "ec2:CreateVpc",
          "ec2:DeleteVpc",
          "ec2:CreateSubnet",
          "ec2:DeleteSubnet",
          "ec2:CreateInternetGateway",
          "ec2:AttachInternetGateway",
          "ec2:CreateNatGateway",
          "ec2:CreateTransitGateway",
          "ec2:ModifyTransitGateway",
          "ec2:CreateTransitGatewayVpcAttachment",
          "ec2:DeleteTransitGateway*",
          "ram:*",
        ]
        Resource = "*"
      },
      {
        Sid      = "DenyAdministratorAccess"
        Effect   = "Deny"
        Action   = ["*"]
        Resource = "*"
        Condition = {
          ArnEquals = {
            "iam:PolicyArn" = "arn:aws:iam::aws:policy/AdministratorAccess"
          }
        }
      },
    ]
  })
}

resource "aws_ssoadmin_account_assignment" "workload_developer" {
  for_each = toset(var.workload_account_ids)

  instance_arn       = var.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.workload_developer[0].arn

  principal_id   = data.aws_identitystore_group.workload_developers[0].group_id
  principal_type = "GROUP"

  target_id   = each.value
  target_type = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_permission_set" "break_glass" {
  name             = "BreakGlass"
  description      = "Emergency access on the management account only."
  instance_arn     = var.instance_arn
  session_duration = "PT1H"
  tags             = var.tags
}

resource "aws_ssoadmin_managed_policy_attachment" "break_glass" {
  instance_arn       = var.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.break_glass.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_ssoadmin_account_assignment" "break_glass" {
  instance_arn       = var.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.break_glass.arn

  principal_id   = data.aws_identitystore_group.break_glass.group_id
  principal_type = "GROUP"

  target_id   = var.management_account_id
  target_type = "AWS_ACCOUNT"
}
