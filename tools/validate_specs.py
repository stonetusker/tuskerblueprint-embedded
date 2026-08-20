#!/usr/bin/env python3
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

import yaml

REQUIRED = {"id", "title", "status", "version", "owner", "reviewers", "created", "updated", "traces_to", "verified_by"}
ALLOWED_STATUS = {"Draft", "In Review", "Approved", "Implemented", "Verified", "Deprecated", "Superseded", "Proposed"}


def parse(path: Path):
    text = path.read_text(encoding="utf-8")
    match = re.match(r"---\n(.*?)\n---\n", text, re.S)
    if not match:
        return None, text, ["missing YAML front matter"]
    errors = []
    try:
        metadata = yaml.safe_load(match.group(1)) or {}
    except yaml.YAMLError as exc:
        return None, text, [f"invalid YAML: {exc}"]
    missing = sorted(REQUIRED - set(metadata))
    if missing:
        errors.append("missing fields: " + ", ".join(missing))
    if metadata.get("status") not in ALLOWED_STATUS:
        errors.append(f"invalid status: {metadata.get('status')}")
    if not re.search(r"^#\s+\S", text[match.end():], re.M):
        errors.append("missing H1 heading")
    return metadata, text, errors


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", default=".")
    args = parser.parse_args()
    root = Path(args.root).resolve()
    ids = {}
    failures = []
    files = sorted(root.rglob("*.md"))
    processed = 0
    for path in files:
        if any(part in {".git", ".venv", "build", ".pytest_cache", "__pycache__"} for part in path.parts) or ".github" in path.parts:
            continue
        processed += 1
        metadata, _, errors = parse(path)
        rel = path.relative_to(root)
        for error in errors:
            failures.append(f"{rel}: {error}")
        if metadata:
            identifier = str(metadata.get("id", "")).strip()
            if identifier in ids:
                failures.append(f"{rel}: duplicate id {identifier}, first used by {ids[identifier]}")
            ids[identifier] = rel
    if failures:
        print("\n".join(failures), file=sys.stderr)
        return 1
    print(f"validated {processed} controlled Markdown specifications with {len(ids)} unique identifiers")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
