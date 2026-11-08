# 003 — Network limits for go-live

## Status

Accepted (cost trade-off)

## Context

The network stack builds a shared Transit Gateway, one egress VPC with a
single NAT gateway, and wires workload VPCs via assume-role providers. Callers
need a hard cap so the example stays predictable and cheap.

## Decision

1. **At most four workload VPCs** are wired by the network stack.
2. **Single-AZ NAT** in the egress VPC — accepted availability SPOF for cost.
3. Dual-NAT / multi-AZ egress and uncapped workload wiring are deferred.

## Consequences

- README, network module README, and handoff state the 4-VPC cap and single-AZ
  NAT SPOF before apply.
- Clients that need HA NAT or more than four workloads must extend outside
  this reference (or wait for a follow-up issue).
