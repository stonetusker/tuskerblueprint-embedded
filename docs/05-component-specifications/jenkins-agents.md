---
id: COMP-006
title: Jenkins Agents
status: Approved
version: 0.2.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-19
updated: 2026-11-16
traces_to:
  - ARCH-001
verified_by:
  []
---

# Jenkins Agents

## Responsibility

Execute Jenkins pipeline stages, limit concurrency, isolate workspaces, protect credentials, and report health.

| Agent label | Host account | Runs | Holds | Never has |
|---|---|---|---|---|
| `yocto-vps8` | build user (Docker group) | CI, nightly, diagnostic and release-candidate build/test stages | Yocto cache, Docker | signing key, Mender token, release-evidence write access |
| `firmware-release` | `release-agent` (no Docker, no sudo) | signing, release-evidence publication, Mender promotion | signing key (0600), `mender-artifact`, `mc` alias `tusker-release` (write, no delete, `release-evidence` only), Mender access token (Jenkins credential) | Docker, Yocto cache, build workspaces |

The build agent runs one executor so full Yocto builds never run concurrently on the host.

## Inputs

- Versioned configuration
- Least-privilege credentials when required
- Immutable build or release identifiers
- Explicit environment selection

## Outputs

- Deterministic status
- Structured logs
- Machine-readable results where applicable
- Evidence linked to the originating build or deployment

## Configuration

Configuration is version-controlled except secrets. Defaults must be safe for local or CI use and must not silently enable production-like authority.

## Failure Modes

- Invalid configuration
- Dependency unavailable
- Timeout or resource exhaustion
- Permission denial
- Corrupt or mismatched artifact
- Incomplete cleanup

Each failure must return non-zero status and preserve actionable evidence.

## Security

The component follows least privilege, validates untrusted input, redacts secrets, and records consequential actions.

## Acceptance

The component is accepted when its traced requirements pass and its runbook has been exercised.
