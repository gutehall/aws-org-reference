# clients

Private per-client directories. Not committed (see root `.gitignore`).

Each client directory holds the values shared modules must not contain:

| Input | Purpose |
|-------|---------|
| Account list | Name, email, role, OU for every member account |
| Region allow list | SCP region guardrail (home region defaults to `eu-north-1`) |
| Group assignments | Identity Center group names bound to permission sets |
| Budget threshold | Spend alarm amount agreed before apply |

## Create a client directory

```sh
mkdir -p clients/<client-slug>
cp examples/terraform.tfvars.example clients/<client-slug>/terraform.tfvars
```

Edit the copy. Keep real emails, account ids, and group names only here.
