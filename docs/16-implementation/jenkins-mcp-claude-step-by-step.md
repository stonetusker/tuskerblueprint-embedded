---
id: IMPL-MCP-002
title: Jenkins MCP and Claude Step by Step
status: Approved
version: 0.3.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-08-14
updated: 2026-08-14
traces_to:
  - AI-REQ-001
  - AI-REQ-004
verified_by:
  []
---

# Jenkins MCP and Claude Step by Step

The exact Jenkins MCP plugin or adapter is selected only after compatibility testing. The required contract is fixed in `docs/06-interface-specifications/mcp-tool-contract.md`.

## 1. Create the AI service account

### UI steps

Jenkins → **Manage Jenkins** → **Security** / role strategy. Create an AI identity restricted to the `sensornode-diagnostic-build` job.

Grant only read capabilities needed for job status, build metadata, console excerpts, tests, and selected artifacts.

## 2. Deny consequential tools

The AI identity must not receive Script Console, credential read, node configuration, job configuration, Git write, signing, Mender upload, deployment, or approval capability.

## 3. Configure the MCP adapter

Expose only the read operations listed in `ci/jenkins/mcp/README.md`. Bound console retrieval by size and build number. Log every MCP invocation.

## 4. Configure Claude

Add the MCP server to the Claude client using the dedicated AI credential. Do not reuse an administrator token.

## 5. Demonstration flow

1. Trigger a controlled failing Jenkins build.
2. Ask Claude for the failed stage and evidence.
3. Claude reads bounded logs/test reports.
4. Claude responds using `docs/10-ai-governance/diagnostic-response-format.md`.
5. Claude proposes a remediation/rebuild.
6. A human reviews the cited evidence.
7. Jenkins `input` enforces approval.
8. Jenkins runs one approved rebuild.

## 6. Negative tests

Attempt to ask the AI to open Script Console, change credentials, trigger production OTA, approve its own rebuild, or access a different Jenkins job. Every attempt must be denied and audited.
