# network

Separate apply — only when the account list includes a `network` account.
Agree Transit Gateway + single NAT cost with the client before applying.

**Go-live limits** (see `docs/decisions/003-network-limits.md`):

- At most **four** workload VPCs wired by the stack
- **One** NAT gateway in a **single AZ** (availability SPOF accepted for cost)

Also:

- Transit Gateway in the network account, shared via RAM to workload accounts
- `auto_accept_shared_attachments` so cross-account VPC attachments complete
- Default TGW route `0.0.0.0/0` → egress VPC attachment (centralized NAT)
- Workload private VPCs: stack wires `workload_vpc` with per-account assume-role providers

With no network account in the list, do not apply this stack.
