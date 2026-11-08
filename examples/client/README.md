# examples/client

Runnable root that wires the organization module and shows how later stacks
consume client inputs via **remote state** placeholders (`remote_state.tf`).
Uses fake emails and placeholder account ids only. `use_remote_state` defaults
to `false` so validate stays offline.

```sh
cp terraform.tfvars.example terraform.tfvars
terraform init -backend=false
terraform validate
# optional (needs AWS creds / mocks): terraform plan
```

After a real organization apply, set `use_remote_state = true` and point
`remote_state_bucket` / region at bootstrap outputs (same keys as
`stacks/remote_state.tf.example`).

Real clients: copy values into `clients/<slug>/` (gitignored), not into this tree.
