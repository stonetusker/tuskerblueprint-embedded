---
id: IMPL-018
title: Build and Cache Execution
status: Approved
version: 0.2.0
owner: Subeesh / Stonetusker Systems
reviewers:
  - Principal Embedded Engineer
  - Platform Engineering
created: 2026-07-20
updated: 2026-07-20
traces_to:
  - ARCH-005
  - ARCH-009
verified_by:
  - TEST-BUILD-001
  - TEST-CACHE-001
---

# Build and Cache Execution

## Build Entry Point

`scripts/build-image.sh` accepts `KAS_FILE`, `IMAGE`, `BUILD_DIR`, `CACHE_DIR`, `ARTIFACT_DIR`, `BUILDER_IMAGE`, and `USE_CONTAINER`.

The container receives:

- repository at `/work`
- selected cache at `/work/cache`
- selected artifact directory at `/work/artifacts`
- a build-specific `KAS_BUILD_DIR`

This alignment is important because `kas/base.yml` configures `DL_DIR` and `SSTATE_DIR` relative to the build top directory.

## Shared Cache

The runner keeps a local working cache for performance. `cache-sync.sh` synchronizes downloads and sstate with MinIO.

Trust rules are explicit:

- pull requests use an isolated cache
- pull operations may continue with a warning if remote cache is unavailable
- push operations require `CACHE_WRITE_ALLOWED=1`
- only successful trusted main builds push
- release artifacts are stored in different buckets and policies

## Benchmark Integrity

`benchmark-build.sh` creates:

- an empty temporary cache and a fresh build directory for the clean case
- the shared cache and a different fresh build directory for the cached case

Using separate fresh build directories prevents BitBake `tmp` reuse from being misreported as sstate performance.

The script records case, elapsed seconds, result, build directory, and cache directory. Public evidence must additionally record CPU allocation, memory, storage, layer revisions, image, and parallelism.

## Outputs

After a successful build, the scripts collect matching images, kernel, Mender artifacts, and checksums into `artifacts/deploy/qemuarm64`. The release manifest then hashes the collected evidence.
