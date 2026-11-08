# network

Separate apply — only when the account list includes a `network` account.
Agree Transit Gateway + single NAT cost with the client before applying.

- Transit Gateway in the network account, shared via RAM to workload accounts
- One egress VPC and one NAT gateway (no Network Firewall, no per-VPC NAT)
- Workload private VPCs: use the `workload_vpc` submodule in each workload
  account (provider assume-role wired in the client stack)

With no network account in the list, do not apply this stack.
