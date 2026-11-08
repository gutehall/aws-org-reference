# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Terraform `required_version` raised to `>= 1.12` (matches CI / `override_during` tests).
- Bootstrap OIDC Terraform role uses a service-scoped landing policy instead of
  `AdministratorAccess` (permissions boundary retained).

### Added

- Decision records for Config scope (log-archive only) and network limits
  (4 workload VPCs, single-AZ NAT).
- `examples/client` remote-state wiring placeholders.
- CONTRIBUTING, SECURITY, dry-run status doc.

## [0.1.0] - TBD

Initial public alpha reference (tag after dry-run and packaging milestones).
