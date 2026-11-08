# organization

Creates member accounts from the client account list and attaches the member
deny SCP to each OU used by that list.

- Exactly one `log-archive` and one `security` (enforced by variable validation).
- Zero or more `workload` accounts; optional `network` account.
- Management account is not created here.
- IAM-user deny is on member OUs only — never on the management account.
- Region allow list is a single variable (default `eu-north-1`). Put any
  global-service exception such as `us-east-1` in that list, not elsewhere.

This module's state is the only state that should edit the organization.
