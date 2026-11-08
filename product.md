# Product

## Vision

Baseline Terraform that lands a client AWS organization from a private tfvars list.

## Problem

Consultants need a repeatable, auditable landing for client orgs without forcing
Control Tower or a fixed five-account map.

## Users

AWS consultants applying into a client's existing management account.

## Architecture

- Shared modules in this repo; real emails/ids/groups only in private `clients/`.
- Management account is never created by the stack.
- Account list requires exactly one `log-archive` and one `security`.
- Network is a separate apply when a `network` account exists.
- First apply: admin session → `bootstrap/`. Later: GitHub OIDC. CI never applies.
- Home region defaults to `eu-north-1`.

## Roadmap

1. Decisions and repo
2. Bootstrap and organization
3. Identity and break-glass
4. Log archive and GuardDuty
5. Network and workload baseline (optional)
6. Tests and CI

## Decisions

| Decision | Rationale | Date |
|----------|-----------|------|
| Account list + separate network | See `docs/decisions/001-account-list-and-network.md` | 2026-11-08 |

## Deferred

Control Tower, account vending, IPAM, Network Firewall, second region, sample app.

## Follow-up

Scaffold landed; gaps tracked in Linear project **aws-org-reference · Make landing work**
(DM3-714+): org integrations, break-glass that fires, Config for real, finished network,
hardening, CI breadth.
