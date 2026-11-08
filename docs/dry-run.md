# Dry-run status

Last updated: 2026-11-08

## Goal

Prove `docs/apply-order.md` end-to-end in a throwaway management account
with Identity Center enabled.

## Outcome

**Full dry-run apply was not run.**

Blocked on a dedicated sandbox management account that:

1. Can host a throwaway organization (or already does).
2. Has Identity Center enabled in the home region with the groups named in
   client tfvars.
3. Is acceptable to create and close member accounts in.

When that apply runs, record pass/fail and any workaround here. Do not record
account ids, organization ids, or principal ARNs.

## Network apply

Skipped with the dry-run. When a sandbox dry-run runs, either apply
`stacks/network` with a `network` account in the list, or record an explicit
skip (cost, or no network role). Limits: see `docs/decisions/003-network-limits.md`.

## Terraform versions

- Declared: `required_version = ">= 1.12"`
- CI pin: Terraform `1.12.2`
