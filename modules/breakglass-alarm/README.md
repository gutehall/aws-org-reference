# breakglass-alarm

Alarms when the BreakGlass permission set is used.

- EventBridge rule on Identity Center / sign-in CloudTrail events → SNS
- Metric filter on the organization trail CloudWatch Logs group → alarm → SNS
- SNS allows the security account to subscribe (not a tag-only claim)
- Confirm email subscriptions in the inbox after apply
