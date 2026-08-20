---
id: IMPL-MANIFEST-001
title: Implementation Asset Manifest
status: Approved
version: 0.2.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-20
updated: 2026-07-20
traces_to:
  - GOV-007
verified_by:
  - TEST-DOC-001
---

# Implementation Asset Manifest

## Package Baseline

- Repository version: `0.2.0`
- Total source and documentation files before archive checksum generation: 319
- Controlled Markdown documents: 197
- Native Yocto metadata and include files: 12
- GitHub Actions workflows: 6
- Repository shell scripts: 17
- Ansible YAML files: 15
- Go source files: 2
- Python source files: 17

## Implemented Technical Areas

| Area | Principal Assets | Validation Level |
|---|---|---|
| SensorNode application | `app/sensornode/` | Go unit tests and host endpoint integration passed |
| Yocto distribution and layer | `meta-sensornode/` | Structural, metadata, shell, and Python review passed; full BitBake build requires network and build host |
| Source pinning and build variants | `kas/` | YAML and policy validation passed; exact commits remain compatibility-spike controlled |
| Reproducible builder | `containers/yocto-builder/` | Dockerfile and entrypoint review passed; image build remains live validation |
| Shared cache | `scripts/cache-sync.sh`, MinIO policies | Script and least-privilege policy review passed; measured benchmark remains live evidence |
| GitHub CI/CD | `.github/workflows/` | YAML and security-policy validation passed; self-hosted execution remains live validation |
| QEMU testing | OEQA tests, direct launcher, host tests | Host tests passed; generated-image boot remains live validation |
| Mender OTA | recipes, state scripts, CLI wrappers | Contract and syntax review passed; A/B integration remains Phase 0 acceptance |
| Jenkins diagnostics | `ci/jenkins/` | Pipeline and approval-boundary review passed; Jenkins/MCP execution remains live validation |
| VPS8 infrastructure | `infra/` | YAML and role structure review passed; target provisioning remains live validation |
| Specification-driven governance | `docs/` and validators | Metadata, link, ID, and traceability validation passed |

## Yocto Assets

- `meta-sensornode/conf/distro/sensornode.conf`
- `meta-sensornode/conf/layer.conf`
- `meta-sensornode/conf/mender-sensornode.inc`
- `meta-sensornode/recipes-core/images/sensornode-image-broken.bb`
- `meta-sensornode/recipes-core/images/sensornode-image-ci.bb`
- `meta-sensornode/recipes-core/images/sensornode-image-dev.bb`
- `meta-sensornode/recipes-core/images/sensornode-image-release.bb`
- `meta-sensornode/recipes-core/images/sensornode-image.inc`
- `meta-sensornode/recipes-core/packagegroups/packagegroup-sensornode.bb`
- `meta-sensornode/recipes-core/sensornode-release/sensornode-release.bb`
- `meta-sensornode/recipes-mender/sensornode-mender-config/sensornode-mender-config.bb`
- `meta-sensornode/recipes-sensornode/sensornode-app/sensornode-app_0.1.0.bb`

## CI Workflows

- `.github/workflows/build-image.yml`
- `.github/workflows/docs.yml`
- `.github/workflows/nightly.yml`
- `.github/workflows/promote-mender.yml`
- `.github/workflows/pull-request.yml`
- `.github/workflows/release-candidate.yml`

## Review Boundary

This manifest distinguishes implemented source from externally dependent acceptance evidence. It does not claim that upstream Yocto sources were fetched, a Mender A/B image was built, the VPS8 was provisioned, or a Jenkins MCP plugin was exercised in this offline environment.
