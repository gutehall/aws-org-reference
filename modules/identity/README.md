# identity

Identity Center permission sets and group assignments by account role.

Identity Center must already be enabled in the home region. Group display
names come from the private client tfvars.

| Permission set | Assignment |
|----------------|------------|
| Administrator | Management only |
| SecurityAuditor | log-archive + security (read-only) |
| NetworkAdmin | network account only, when present |
| WorkloadDeveloper | every workload account; no AdministratorAccess, IAM, or network changes |
| BreakGlass | Management only |

Break-glass principals (shared with logging delete exception and the alarm):

- IAM role `BreakGlass` in the management account (stable ARN)
- SSO role pattern `AWSReservedSSO_BreakGlass_*` in the management account

Pass `break_glass_allowed_principal_arns` into the logging stack.
