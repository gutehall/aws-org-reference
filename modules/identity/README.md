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
