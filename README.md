# aws-org-reference

Baseline Terraform you apply to land a client AWS organization from a private
tfvars list. For AWS consultants applying into a client's **existing**
management account.

Member accounts come from that list. Exactly one `log-archive` and one
`security` role are required. The network is a separate apply, only when the
list includes a `network` account.

## What this is not

- Not AWS Control Tower / Account Factory / AFT
- Not multi-region, IPAM, Network Firewall, or account vending
- Not org-wide AWS Config (recorder is log-archive only — see
  [`docs/decisions/002-config-scope.md`](docs/decisions/002-config-scope.md))
- Not production-certified until dry-run milestones close

## Layout

| Path | Role |
|------|------|
| `bootstrap/` | One-time management-account apply: state backend, then GitHub OIDC |
| `modules/` | Shared modules (organization, identity, logging, guardduty, budget, network, …) |
| `stacks/` | Root modules that wire providers and call modules |
| `examples/` | Public shape of client inputs — fake emails, no account ids |
| `clients/` | Private per-client directory (gitignored). Holds real tfvars |
| `docs/` | Decision records, apply order, handoff, dry-run status |

See `docs/decisions/001-account-list-and-network.md` and `docs/handoff.md`.

Client emails, account ids, and group membership stay in `clients/`. Shared
modules never contain them. `product.md` is maintainer-oriented.

## Requirements

- Terraform `>= 1.12` (CI pins `1.12.2`)
- AWS provider `hashicorp/aws` `~> 6.0`
- A management account that already exists (this stack does not create it)
- Identity Center enabled in the home region before identity applies

## Limitations (go-live)

| Topic | Constraint |
|-------|------------|
| Dry-run | Full apply not yet completed in a throwaway org (`docs/dry-run.md`) |
| Network | Up to **4** workload VPCs; **single-AZ NAT** (availability SPOF for cost) — [`003`](docs/decisions/003-network-limits.md) |
| Config | Log-archive recorder only — [`002`](docs/decisions/002-config-scope.md) |
| OIDC role | Service-scoped landing policy + permissions boundary; not `AdministratorAccess`. Member work still uses `OrganizationAccountAccessRole` after assume-role |
| Break-glass alerts | EventBridge / metric patterns best-effort until verified against real SSO events |

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
   `network` role (agree TGW + single-NAT cost first).

5. Wire later stacks from org / identity / logging outputs via remote state.
   The supported shape is in `examples/client/remote_state.tf` (placeholders
   for offline validate); `stacks/remote_state.tf.example` is the copy-paste
   hint for real client roots.

## License

MIT
