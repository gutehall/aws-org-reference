# Contributing

This is a Terraform reference for landing a client AWS organization. Changes
should stay small, tested, and honest about scope (see README limitations).

## Prerequisites

- Terraform `>= 1.12` (CI uses `1.12.2`)
- AWS provider `~> 6.0` (installed by `terraform init`)

## Local checks

From the repo root:

```sh
terraform fmt -check -recursive

terraform -chdir=bootstrap init -backend=false && terraform -chdir=bootstrap validate
terraform -chdir=stacks/organization init -backend=false && terraform -chdir=stacks/organization validate
# Repeat for stacks/identity, logging, guardduty, network, budget, breakglass-alarm

cp examples/client/terraform.tfvars.example examples/client/terraform.tfvars
terraform -chdir=examples/client init -backend=false && terraform -chdir=examples/client validate

terraform -chdir=stacks/organization test
terraform -chdir=stacks/logging test
terraform -chdir=stacks/identity test
terraform -chdir=stacks/network test
```

Optional Checkov (matches CI):

```sh
checkov -f . --config-file .checkov.yaml --framework terraform --skip-path '**/.terraform/**'
```

## Rules of thumb

- Real client emails, account ids, and groups belong in `clients/` (gitignored),
  never in `examples/` or modules.
- Module CI never assumes the client Terraform OIDC role and never applies.
- Prefer decision records under `docs/decisions/` when changing product scope.
