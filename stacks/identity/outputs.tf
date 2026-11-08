output "permission_sets" {
  value = module.identity.permission_sets
}

output "break_glass_permission_set_arn" {
  value = module.identity.break_glass_permission_set_arn
}

output "break_glass_role_arn" {
  value = module.identity.break_glass_role_arn
}

output "break_glass_allowed_principal_arns" {
  value = module.identity.break_glass_allowed_principal_arns
}
