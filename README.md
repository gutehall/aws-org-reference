# aws-org-reference

Baseline Terraform you apply to land a client AWS organization.

Member accounts come from a private tfvars list. Exactly one `log-archive` and
one `security` role are required. The network is a separate apply, only when
the list includes a `network` account.

## Layout

| Path | Role |
|------|------|
| `bootstrap/` | One-time management-account apply: state backend, then GitHub OIDC |
| `modules/` | Shared modules (organization, identity, logging, guardduty, budget, network, …) |
| `stacks/` | Root modules that wire providers and call modules |
| `examples/` | Public shape of client inputs — fake emails, no account ids |
| `clients/` | Private per-client directory (gitignored). Holds real tfvars |
| `docs/` | Decision records and handoff contract |

See `docs/decisions/001-account-list-and-network.md` and `docs/handoff.md`.

Client emails, account ids, and group membership stay in `clients/`. Shared
modules never contain them.

## Requirements

- Terraform `>= 1.10`
- AWS provider `hashicorp/aws` `~> 6.0`
- A management account that already exists (this stack does not create it)
- Identity Center enabled in the home region before identity applies

## Quick start

See **`docs/apply-order.md`** for the full sequence and prerequisites.

1. Copy `examples/terraform.tfvars.example` into a private client directory:

   ```sh
   mkdir -p clients/acme
   cp examples/terraform.tfvars.example clients/acme/terraform.tfvars
   ```

2. Edit the client file: account list, region allow list, group assignments,
   and budget threshold. Pre-create the Identity Center groups named there.

3. Apply `bootstrap/` once from an administrator session in the management
   account. Later applies can use GitHub OIDC for that client repository.

4. Apply `stacks/organization` (import the existing org on first apply — see
   apply-order). Then identity → logging → GuardDuty → budget → break-glass.
   Confirm the SNS email subscription. Apply network only when the list has a
   `network` role.

5. Wire later stacks from org/identity/logging outputs (see
   `stacks/remote_state.tf.example`).

## License

MIT
