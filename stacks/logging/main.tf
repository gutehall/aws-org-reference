provider "aws" {
  region = var.home_region
}

provider "aws" {
  alias  = "log_archive"
  region = var.home_region

  dynamic "assume_role" {
    for_each = var.assume_log_archive_role ? [1] : []
    content {
      role_arn = "arn:aws:iam::${var.log_archive_account_id}:role/OrganizationAccountAccessRole"
    }
  }
}

module "logging" {
  source = "../../modules/logging"

  providers = {
    aws             = aws
    aws.log_archive = aws.log_archive
  }

  home_region            = var.home_region
  log_archive_account_id = var.log_archive_account_id
  management_account_id  = var.management_account_id
  break_glass_role_arn   = var.break_glass_role_arn
  name_prefix            = var.name_prefix
  tags                   = var.tags
}
