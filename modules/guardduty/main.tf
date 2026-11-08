resource "aws_guardduty_organization_admin_account" "security" {
  admin_account_id = var.security_account_id
}

resource "aws_guardduty_detector" "security" {
  provider = aws.security

  enable = true
  tags   = var.tags

  depends_on = [aws_guardduty_organization_admin_account.security]
}

resource "aws_guardduty_organization_configuration" "security" {
  provider = aws.security

  detector_id                      = aws_guardduty_detector.security.id
  auto_enable_organization_members = "ALL"

  depends_on = [aws_guardduty_organization_admin_account.security]
}
