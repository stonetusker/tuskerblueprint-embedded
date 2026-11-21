---
id: ADR-009
title: Use a Constrained Jenkins MCP Integration
status: Approved
version: 1.0.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-19
updated: 2026-11-20
traces_to:
  - AI-REQ-001
  - AI-REQ-003
  - AI-REQ-005
verified_by:
  - TEST-AI-001
  - TEST-AI-003
---

# Use a Constrained Jenkins MCP Integration

## Status

Accepted 2026-11-20. This supersedes the Proposed status of 2026-07-20.

## Context

The AI story depends on safe evidence access, not plugin novelty. The integration must expose only the read tools in INT-009. It must bound and redact what it returns, audit every call, and leave all consequential actions to Jenkins RBAC and the `input` step.

## Decision

Implement a constrained adapter, `ci/jenkins/mcp/jenkins_mcp_server.py`. It is a stdio MCP server, uses only the Python standard library, and runs beside the Claude client with a dedicated read-only Jenkins account.

A Jenkins-side MCP plugin was not selected, for four reasons:

- It runs inside the controller.
- It offers tools such as triggering builds, which can only be blocked by permissions and not removed from the tool surface.
- It does not apply this project's redaction, untrusted-data fencing, job and artifact allowlists, or JSONL audit format.

The adapter is generic Jenkins diagnostics, not a Yocto-specific MCP server.

## Consequences

- Two independent layers deny consequential actions: the adapter has no write code path, and the Jenkins account has only Overall/Read and Job/Read.
- No plugin is installed in the controller, so Jenkins upgrades do not depend on MCP plugin compatibility.
- The project maintains about 600 lines of Python and their unit tests (`make mcp-test`).
- Each Claude user runs the adapter locally with their own token, so audit logs are per machine unless `JENKINS_MCP_AUDIT_LOG` points at shared storage.
- Changes to the tool surface require updating INT-009 and this ADR.

## Alternatives Considered

- **Jenkins MCP Server plugin in the controller.** Rejected for the reasons above. Reconsider if it gains per-tool allowlists and redaction hooks.
- **A direct Jenkins API wrapper given to Claude as shell `curl` commands.** Rejected: unbounded, unaudited, and the token is exposed to the model's tool calls.
- **No AI integration.** Rejected: it removes episode 6 and the diagnostic use case.
