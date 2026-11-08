# bootstrap

First apply from an administrator session in the client's management account.

Creates:

- S3 state bucket and DynamoDB lock table in the management account
- GitHub OIDC provider and a Terraform IAM role trusted for one repository

Later applies for that client can assume the role via OIDC. No static access
keys. The shared module repository's CI must not assume this role and must
not run `terraform apply`.

## Apply once

```sh
cp terraform.tfvars.example terraform.tfvars
# set github_repository to the private client apply repo
terraform init
terraform apply
```

Use the `backend_config_hcl` output for later stacks.
