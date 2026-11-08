# Manage the existing organization in-place (import on first apply).
# Enables SCP policy type and trusted access so other stacks do not need console clicks.
resource "aws_organizations_organization" "this" {
  aws_service_access_principals = var.aws_service_access_principals
  enabled_policy_types          = ["SERVICE_CONTROL_POLICY"]
  feature_set                   = "ALL"

  lifecycle {
    prevent_destroy = true
  }
}

locals {
  ou_names = toset([for a in var.accounts : a.ou])

  accounts_by_key = {
    for a in var.accounts : a.name => a
  }

  root_id = aws_organizations_organization.this.roots[0].id
}

resource "aws_organizations_organizational_unit" "this" {
  for_each = local.ou_names

  name      = each.value
  parent_id = local.root_id
}

resource "aws_organizations_account" "this" {
  for_each = local.accounts_by_key

  name      = each.value.name
  email     = each.value.email
  parent_id = aws_organizations_organizational_unit.this[each.value.ou].id
  role_name = "OrganizationAccountAccessRole"

  # Close on destroy is dangerous in production; prefer remove from org manually.
  close_on_deletion = false

  tags = merge(
    var.tags,
    {
      Role = each.value.role
    },
  )

  lifecycle {
    ignore_changes = [
      # Email cannot change after create; role_name is create-time only.
      role_name,
    ]
  }
}
