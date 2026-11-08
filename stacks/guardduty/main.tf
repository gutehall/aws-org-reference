provider "aws" {
  region = var.home_region
}

provider "aws" {
  alias  = "security"
  region = var.home_region

  assume_role {
    role_arn = "arn:aws:iam::${var.security_account_id}:role/OrganizationAccountAccessRole"
  }
}

module "guardduty" {
  source = "../../modules/guardduty"

  providers = {
    aws          = aws
    aws.security = aws.security
  }

  security_account_id = var.security_account_id
  home_region         = var.home_region
  name_prefix         = var.name_prefix
  tags                = var.tags
}
