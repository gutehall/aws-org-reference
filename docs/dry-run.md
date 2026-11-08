# Dry-run status

Last updated: 2026-11-08

## Goal

Prove `docs/apply-order.md` end-to-end in a **throwaway** management account
with Identity Center enabled (Linear DM3-732 / DM3-733 / DM3-735).

## Current environment check (2026-11-08)

| Check | Result |
|-------|--------|
| Caller | `arn:aws:iam::000000000000:user/example` |
| Organization | Exists (`o-xxxxxxxxxx`), feature set `ALL`, management = this account |
| Member accounts | None (management only) |
| Identity Center | **Not enabled** (`list-instances` → null) |
| Throwaway? | **No** — personal / named management account |

## Outcome

**Full dry-run apply was not run.** Creating member accounts and enabling
Identity Center in this account is out of scope for a throwaway proof.

Blocked on a dedicated sandbox management account that:

1. Can host a throwaway organization (or already does).
2. Has Identity Center enabled in the home region with the groups named in
   client tfvars.
3. Is acceptable to create/close member accounts in.

## Network apply

Skipped with the dry-run. When a sandbox dry-run runs, either apply
`stacks/network` with a `network` account in the list, or record an explicit
skip (cost / no network role). Limits: see `docs/decisions/003-network-limits.md`.

## Terraform versions

- Declared: `required_version = ">= 1.12"`
- CI pin: Terraform `1.12.2`

## Follow-ups

- DM3-732 — complete apply in throwaway org
- DM3-735 — verify break-glass EventBridge against real SSO events
- DM3-733 — expand this file with pass/fail and workarounds after that apply
