locals {
  # Deny use of regions outside the allow list. NotAction keeps IAM / Orgs /
  # global billing and support APIs usable from any region.
  region_deny_statement = {
    Sid    = "DenyOutsideRegionAllowList"
    Effect = "Deny"
    # Why: clients agree a home region; runaway multi-region spend and shadow IT stay out.
    NotAction = [
      "a4b:*",
      "acm:*",
      "aws-marketplace-management:*",
      "aws-marketplace:*",
      "aws-portal:*",
      "budgets:*",
      "ce:*",
      "chime:*",
      "cloudfront:*",
      "config:*",
      "cur:*",
      "directconnect:*",
      "ec2messages:*",
      "globalaccelerator:*",
      "health:*",
      "iam:*",
      "importexport:*",
      "mobilemarketing:*",
      "networkmanager:*",
      "organizations:*",
      "pricing:*",
      "route53:*",
      "route53domains:*",
      "s3:GetBucketLocation",
      "s3:ListAllMyBuckets",
      "shield:*",
      "sts:*",
      "support:*",
      "trustedadvisor:*",
      "waf-regional:*",
      "waf:*",
      "wafv2:*",
      "wellarchitected:*",
    ]
    Resource = "*"
    Condition = {
      StringNotEquals = {
        "aws:RequestedRegion" = var.region_allow_list
      }
    }
  }

  # Shared deny list for every OU that holds member accounts.
  member_deny_statements = [
    {
      Sid    = "DenyLeaveOrganization"
      Effect = "Deny"
      # Why: a member account must not detach itself from the landed org.
      Action   = ["organizations:LeaveOrganization"]
      Resource = "*"
    },
    {
      Sid    = "DenyDisableCloudTrail"
      Effect = "Deny"
      # Why: organization trail evidence must stay on.
      Action = [
        "cloudtrail:DeleteTrail",
        "cloudtrail:StopLogging",
        "cloudtrail:UpdateTrail",
      ]
      Resource = "*"
    },
    {
      Sid    = "DenyDisableGuardDuty"
      Effect = "Deny"
      # Why: detection must stay enrolled after landing.
      Action = [
        "guardduty:DeleteDetector",
        "guardduty:DisassociateFromMasterAccount",
        "guardduty:DisassociateMembers",
        "guardduty:StopMonitoringMembers",
        "guardduty:DeleteMembers",
        "guardduty:DisableOrganizationAdminAccount",
      ]
      Resource = "*"
    },
    local.region_deny_statement,
    {
      Sid    = "DenyCreateIamUsers"
      Effect = "Deny"
      # Why: Identity Center is the front door; long-lived IAM users in members stay out.
      # This statement is attached only to member OUs — never to the management account.
      Action = [
        "iam:CreateUser",
        "iam:CreateAccessKey",
      ]
      Resource = "*"
    },
  ]

  member_scp = jsonencode({
    Version   = "2012-10-17"
    Statement = local.member_deny_statements
  })
}

resource "aws_organizations_policy" "member_deny" {
  name        = "aws-org-reference-member-deny"
  description = "Deny leave-org, disable CloudTrail/GuardDuty, out-of-region use, and IAM users in member accounts."
  type        = "SERVICE_CONTROL_POLICY"
  content     = local.member_scp

  tags = var.tags
}

resource "aws_organizations_policy_attachment" "member_deny" {
  for_each = aws_organizations_organizational_unit.this

  policy_id = aws_organizations_policy.member_deny.id
  target_id = each.value.id
}
