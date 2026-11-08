output "permission_sets" {
  description = "Permission set names and ARNs for the handoff."
  value = merge(
    {
      Administrator = {
        arn   = aws_ssoadmin_permission_set.administrator.arn
        group = var.groups.administrators
      }
      SecurityAuditor = {
        arn   = aws_ssoadmin_permission_set.security_auditor.arn
        group = var.groups.security_auditors
      }
      BreakGlass = {
        arn   = aws_ssoadmin_permission_set.break_glass.arn
        group = var.groups.break_glass
      }
    },
    var.network_account_id == null ? {} : {
      NetworkAdmin = {
        arn   = aws_ssoadmin_permission_set.network_admin[0].arn
        group = var.groups.network_admins
      }
    },
    length(var.workload_account_ids) == 0 ? {} : {
      WorkloadDeveloper = {
        arn   = aws_ssoadmin_permission_set.workload_developer[0].arn
        group = var.groups.workload_developers
      }
    },
  )
}

output "break_glass_permission_set_arn" {
  description = "BreakGlass permission set ARN (for CloudTrail / EventBridge alarms)."
  value       = aws_ssoadmin_permission_set.break_glass.arn
}

output "break_glass_permission_set_name" {
  value = aws_ssoadmin_permission_set.break_glass.name
}

output "break_glass_role_arn" {
  description = "Stable IAM BreakGlass role ARN in the management account."
  value       = aws_iam_role.break_glass.arn
}

output "break_glass_allowed_principal_arns" {
  description = "Principals allowed to delete log-archive objects: IAM BreakGlass role and SSO BreakGlass role pattern. Pass to logging."
  value       = local.break_glass_allowed_principal_arns
}
