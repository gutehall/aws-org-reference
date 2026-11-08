# examples/client

Runnable root that wires the organization module and shows how later stacks
consume client inputs. Uses fake emails and placeholder account ids only.

```sh
cp terraform.tfvars.example terraform.tfvars
terraform init -backend=false
terraform validate
# optional (needs AWS creds / mocks): terraform plan
```

Real clients: copy values into `clients/<slug>/` (gitignored), not into this tree.
