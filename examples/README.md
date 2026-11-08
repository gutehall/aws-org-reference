# examples

- `terraform.tfvars.example` — public shape of client inputs (fake emails).
- `client/` — runnable root: `terraform init -backend=false && terraform validate`
  with the example tfvars. Wires the organization module, remote-state
  placeholders, and previews later-stack inputs.
