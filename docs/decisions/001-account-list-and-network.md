# 001 — Accounts are a list; network is a separate apply

## Status

Accepted

## Context

Landing a client organization needs member accounts, guardrails, and optional
shared networking. The management account already exists. Clients differ in
how many workload accounts they want, and not every client wants a shared
network account on day one.

## Decision

1. **Member accounts are a list.** Each entry has a name, email, role, and OU.
   Exactly one role is `log-archive` and exactly one is `security`. Any number
   of other accounts is valid, including none. The organization stack creates
   one account per list entry.

2. **The management account is not created by the stack.** It is the apply
   target. It never appears in the account list.

3. **The network module is a separate apply.** It runs only when the list
   contains a `network` account. Its cost (Transit Gateway, centralized NAT)
   is agreed with the client before that apply. Workload VPCs attach to the
   shared network; they do not each get a NAT gateway.

## Alternatives considered

| Alternative | Why not |
|-------------|---------|
| Fixed five-account map (mgmt + log + security + network + workload) | Forces a network account and a workload account on every client. Inflates the monthly floor for landings that only need log-archive and security. |
| Control Tower / Account Factory | Heavier than this baseline. Account vending, IPAM, and related services stay out of scope. Clients who need Control Tower can adopt it later without this repo pretending to be it. |

## Consequences

- Appending a workload account is one list object and another apply. Guardrails
  bind to `role`, so no module change is required for a new workload entry.
- A minimum landing is two member accounts: `log-archive` and `security`.
- Network cost stays optional and visible. Org, identity, and logging state
  stay independent of the network apply.
