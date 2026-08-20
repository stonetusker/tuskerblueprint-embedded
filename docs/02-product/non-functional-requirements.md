---
id: PRD-006
title: Non-Functional Requirements
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

# Non-Functional Requirements

- **Reproducibility:** Inputs and tool versions are pinned.
- **Security:** Least privilege, signing, secret isolation, protected branches.
- **Reliability:** Timeouts, cleanup, retry policy, canary rollout, rollback.
- **Auditability:** Builds, approvals, promotions, and AI interactions are recorded.
- **Maintainability:** Shared scripts separate implementation from orchestrators.
- **Portability:** Project C is standalone and has a documented shared-platform migration path.
- **Performance:** Build caching is measured, not assumed.
- **Clarity:** QEMU claims do not imply physical-board certification.
