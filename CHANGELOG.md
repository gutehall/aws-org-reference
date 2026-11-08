# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-11-08

Initial private alpha reference.

### Added

- Bootstrap (state backend + GitHub OIDC), organization / identity / logging /
  GuardDuty / budget / break-glass / optional network stacks and modules.
- Decision records for account list, Config scope (log-archive only), and
  network limits (4 workload VPCs, single-AZ NAT).
- `examples/client` remote-state wiring placeholders.
- CONTRIBUTING, SECURITY, apply-order, handoff, dry-run status docs.
- CI: Terraform validate, tests, Checkov.

### Changed

- Terraform `required_version` `>= 1.12` (CI pins `1.12.2`).
- Bootstrap OIDC Terraform role uses a service-scoped landing policy instead of
  `AdministratorAccess` (permissions boundary retained).
