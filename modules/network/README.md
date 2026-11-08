# network

Separate apply — only when the account list includes a `network` account.
Agree Transit Gateway + single NAT cost with the client before applying.

- Transit Gateway in the network account, shared via RAM to workload accounts
- `auto_accept_shared_attachments` so cross-account VPC attachments complete
- Default TGW route `0.0.0.0/0` → egress VPC attachment (centralized NAT)
- One egress VPC and one NAT gateway in a single AZ (availability SPOF accepted for cost)
- Workload private VPCs: stack wires `workload_vpc` with per-account assume-role providers (up to 4)

With no network account in the list, do not apply this stack.
