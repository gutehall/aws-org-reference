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
| Config log-archive only (MVP) | See `docs/decisions/002-config-scope.md` | 2026-11-08 |
| Network 4-VPC / single-AZ NAT | See `docs/decisions/003-network-limits.md` | 2026-11-08 |

## Deferred

Control Tower, account vending, IPAM, Network Firewall, second region, sample app.

## Follow-up

Scaffold and landing fixes are done. v0.1.0 is tagged. The open proof is a
dry-run apply in a throwaway organization (`docs/dry-run.md`).
