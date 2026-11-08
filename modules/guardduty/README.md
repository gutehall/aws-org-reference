# guardduty

Delegates GuardDuty to the security account and auto-enrolls current and
future organization members.

Findings export:

- S3 publishing destination in the security account (KMS-encrypted)
- EventBridge rule `GuardDuty Finding` on the security account default bus
  (attach your SIEM target in the client stack)

Included in the monthly floor on the handoff.
