# Apply order

## Prerequisites (manual)

- Management account already exists (this repo never creates it).
- Identity Center enabled in the home region (`eu-north-1` by default).
- Identity Center **groups** named in the client tfvars already exist.
- Administrator credentials (or equivalent) for the first bootstrap apply.

## Sequence

1. **`bootstrap/`** (admin session in management)  
   State bucket (TLS-only), lock table, GitHub OIDC role for the *client* apply
   repo (permissions boundary applied).  
   Module CI never assumes this role and never applies.

2. **`stacks/organization`**  
   Import the existing org on first apply:
   ```sh
   terraform import 'module.organization.aws_organizations_organization.this' o-xxxxxxxxxx
   ```
   Enables `SERVICE_CONTROL_POLICY` and trusted access for CloudTrail, Config,
   GuardDuty, and RAM. Creates member accounts and attaches the member deny SCP.

3. **`stacks/identity`**  
   Permission sets by account role. Outputs `break_glass_allowed_principal_arns`
   (IAM `BreakGlass` role + SSO pattern) for logging.

4. **`stacks/logging`**  
   Org trail → S3 + CloudWatch Logs; Config recorder in log-archive; bucket
   deny-delete except break-glass principals; optional VPC flow-log allows.

5. **`stacks/guardduty`** → **`stacks/budget`** → **`stacks/breakglass-alarm`**  
   Confirm SNS email subscriptions after the alarm stack apply. Security
   account may subscribe to the break-glass SNS topic.

6. **`stacks/network`** (only if the account list has a `network` role)  
   Agree TGW + single-NAT cost first. Wires up to four `workload_vpc` modules
   via assume-role providers. Pass `flow_logs_bucket_arn` from logging.

## Wiring outputs

Use remote state (see `stacks/remote_state.tf.example`) so later stacks consume
org / identity / logging outputs instead of pasting account ids by hand.
