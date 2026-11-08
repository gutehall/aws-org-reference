provider "aws" {
  region = var.home_region
}

module "breakglass_alarm" {
  source = "../../modules/breakglass-alarm"

  home_region                    = var.home_region
  alert_email                    = var.alert_email
  security_alert_email           = var.security_alert_email
  break_glass_permission_set_arn = var.break_glass_permission_set_arn
  cloudtrail_log_group_name      = var.cloudtrail_log_group_name
  security_account_id            = var.security_account_id
  name_prefix                    = var.name_prefix
  tags                           = var.tags
}
