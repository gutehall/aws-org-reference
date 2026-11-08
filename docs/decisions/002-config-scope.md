# 002 — Config scope for go-live

## Status

Accepted

## Context

AWS Config can record in one account or across the organization (aggregator /
member recorders). The logging module today creates a recorder and delivery
channel only in the log-archive account, writing under `config/` on the org
trail bucket.

## Decision

**Ship log-archive-only Config as the v0.1.0 MVP.** Do not claim org-wide
Config coverage. Org-wide aggregators and member recorders are deferred.

## Alternatives considered

| Alternative | Why not (for v0.1.0) |
|-------------|----------------------|
| Org Config aggregator + member recorders | Extra cost and cross-account wiring; not required to prove the landing path. |
| No Config at all | Loses a useful history trail in the account that already holds CloudTrail. |

## Consequences

- Handoff and README state Config history for log-archive only.
- Expanding to org-wide Config needs a follow-up issue with estimate before
  go-live claims change.
