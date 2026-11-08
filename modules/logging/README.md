# logging

Organization CloudTrail and Config history landing in the log-archive account.

Separate from GuardDuty so the trail can be reviewed on its own. The bucket
policy denies `s3:DeleteObject` for every principal except the break-glass
role. VPC flow logs wait for the network module.
