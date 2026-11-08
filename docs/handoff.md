# Client handoff

After apply, stack outputs are the note the client keeps. Nothing in this note
is assembled by hand.

## Account lines

One line per entry in the account list:

```
<name>  <account-id>  <role>
```

The management account is not in the list and is not printed here. Account ids
come from the organization stack after create.

## Identity Center

- Sign-in URL for the client's Identity Center instance.
- Which group holds which permission set:

| Permission set | Group (from tfvars) | Accounts |
|----------------|---------------------|----------|
| Administrator | `groups.administrators` | Management only |
| SecurityAuditor | `groups.security_auditors` | log-archive, security |
| NetworkAdmin | `groups.network_admins` | network (only when present) |
| WorkloadDeveloper | `groups.workload_developers` | every `workload` account |
| BreakGlass | `groups.break_glass` | Management only |

## Logging and detection

- Organization CloudTrail destination: bucket in the log-archive account, and CloudWatch Logs.
- Config history: Config recorder in the log-archive account delivering to that bucket.
- GuardDuty delegated administrator: the security account.
- Break-glass: EventBridge + metric filter → SNS to the email in tfvars (confirm subscription). Security account may subscribe to the same SNS topic. Delete exception uses the shared break-glass principals from identity (IAM `BreakGlass` role + `AWSReservedSSO_BreakGlass_*`).

## Guardrails (plain language)

The attached SCPs deny:

1. Leaving the organization.
2. Disabling CloudTrail.
3. Disabling GuardDuty.
4. Using a region outside the allow list (see tfvars; home region defaults to
   `eu-north-1`).
5. Creating IAM users in any member account (not attached to management).

## Cost

- Budget threshold: the amount from tfvars.
- Monthly floor: GuardDuty + CloudTrail storage + the accounts in the list.
  The network module (Transit Gateway, centralized NAT) is extra and only
  when that separate apply runs.

## Adding an account later

1. Append one object to `accounts` in the private client tfvars (name, email,
   role, ou).
2. Apply the organization stack again.
3. Identity and logging follow from `role` — no module change for a new
   `workload` entry.
4. If you add a `network` role for the first time, plan the separate network
   apply and its cost with the client before running it.
