# logging

Organization CloudTrail and Config history landing in the log-archive account.

- Trail → S3 (immutable delete deny except break-glass principals) and CloudWatch Logs
- Config recorder + delivery channel in log-archive only (not org-wide), writing under `config/`
- Bucket policy allows VPC flow log delivery from `flow_log_source_account_ids`

Separate from GuardDuty so the trail can be reviewed on its own.
