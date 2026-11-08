# Security

## Reporting a vulnerability

Email the maintainer listed on the GitHub repository (or open a private
security advisory on GitHub if enabled). Please include:

- Affected path (module / stack / bootstrap)
- Description and impact
- Reproduction steps or a minimal plan/apply excerpt

Do not file public issues for undisclosed vulnerabilities.

## Design notes

- Bootstrap attaches a **service-scoped** landing policy to the GitHub OIDC
  Terraform role, plus a permissions boundary that denies common escalations.
  It does **not** use `AdministratorAccess`.
- Module CI never assumes that role and never runs `terraform apply`.
- Break-glass is intentional admin access; SNS alerts should be confirmed after
  apply. Treat EventBridge / metric-filter patterns as best-effort until
  verified in a dry-run org (see `docs/dry-run.md`).
