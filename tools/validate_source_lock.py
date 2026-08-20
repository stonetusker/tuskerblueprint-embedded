#!/usr/bin/env python3
from __future__ import annotations
import argparse, re
from pathlib import Path
import yaml

SHA_RE = re.compile(r"^[0-9a-f]{40}$")

ap = argparse.ArgumentParser()
ap.add_argument("path", nargs="?", default="kas/source-lock.yml")
ap.add_argument("--require-mender", action="store_true")
args = ap.parse_args()
p = Path(args.path)
if not p.is_file():
    raise SystemExit(f"missing source lock: {p}; run make source-lock and commit the result")
data = yaml.safe_load(p.read_text(encoding="utf-8")) or {}
repos = data.get("repos") or {}
required = {"poky", "meta-openembedded"}
if args.require_mender:
    required.add("meta-mender")
missing = sorted(required - set(repos))
if missing:
    raise SystemExit(f"source lock missing repositories: {', '.join(missing)}")
for name, cfg in repos.items():
    commit = str((cfg or {}).get("commit", ""))
    if not SHA_RE.fullmatch(commit):
        raise SystemExit(f"source lock for {name} is not an immutable 40-hex commit: {commit!r}")
print(f"validated immutable source lock for {len(repos)} repositories")
