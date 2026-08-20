---
id: GOV-005
title: Specification Governance
status: Approved
version: 0.2.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-19
updated: 2026-07-20
traces_to:
  []
verified_by:
  []
---

# Specification Governance

## Status Model

Documents use: Draft, In Review, Approved, Implemented, Verified, Deprecated, or Superseded.

## Authority

The project owner approves product scope. Embedded engineering approves Yocto and target changes. Platform engineering approves CI and infrastructure changes. Security review is mandatory for signing, secrets, AI permissions, OTA promotion, and external exposure.

## Document Rules

- Every controlled document has YAML front matter.
- Every requirement has a stable identifier.
- Every test names the requirements it verifies.
- Superseded decisions remain in Git history and are marked explicitly.
- Generated logs are stored outside Git; Markdown summaries and hashes remain in Git.
