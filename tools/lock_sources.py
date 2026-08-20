#!/usr/bin/env python3
"""Resolve kas repository branch/tag references to immutable Git commits.

This tool is intentionally network-dependent. It does not clone repositories; it
uses `git ls-remote` to resolve the refs found in the supplied kas files and
writes a small kas overlay that replaces only the `commit` values.
"""
from __future__ import annotations

import argparse
import re
import subprocess
from pathlib import Path
from typing import Dict, Tuple

import yaml

SHA_RE = re.compile(r"^[0-9a-fA-F]{40}$")


def load_repos(paths: list[Path]) -> Dict[str, Tuple[str, str]]:
    repos: Dict[str, Tuple[str, str]] = {}
    for path in paths:
        data = yaml.safe_load(path.read_text(encoding="utf-8")) or {}
        for name, cfg in (data.get("repos") or {}).items():
            if not isinstance(cfg, dict) or "url" not in cfg:
                continue
            ref = str(cfg.get("commit", "")).strip()
            if not ref:
                raise SystemExit(f"{path}: repo {name} has no commit/ref")
            repos[name] = (str(cfg["url"]), ref)
    return repos


def resolve(url: str, ref: str) -> str:
    if SHA_RE.fullmatch(ref):
        return ref.lower()
    candidates = [f"refs/heads/{ref}", f"refs/tags/{ref}^{{}}", f"refs/tags/{ref}"]
    for candidate in candidates:
        proc = subprocess.run(
            ["git", "ls-remote", url, candidate],
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=False,
        )
        if proc.returncode != 0:
            raise SystemExit(f"git ls-remote failed for {url}: {proc.stderr.strip()}")
        lines = [line for line in proc.stdout.splitlines() if line.strip()]
        if lines:
            sha = lines[0].split()[0]
            if SHA_RE.fullmatch(sha):
                return sha.lower()
    raise SystemExit(f"cannot resolve {ref!r} from {url}")


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument(
        "--config",
        action="append",
        default=[],
        help="kas file containing repository URLs; may be repeated",
    )
    ap.add_argument("--output", default="kas/source-lock.yml")
    args = ap.parse_args()

    configs = [Path(p) for p in (args.config or ["kas/base.yml", "kas/mender.yml"])]
    for p in configs:
        if not p.is_file():
            raise SystemExit(f"missing kas config: {p}")

    repos = load_repos(configs)
    if not repos:
        raise SystemExit("no remote repositories found")

    locked = {}
    for name in sorted(repos):
        url, ref = repos[name]
        sha = resolve(url, ref)
        print(f"{name}: {ref} -> {sha}")
        locked[name] = {"commit": sha}

    out = Path(args.output)
    out.parent.mkdir(parents=True, exist_ok=True)
    payload = {
        "header": {"version": 14},
        "repos": locked,
    }
    out.write_text(yaml.safe_dump(payload, sort_keys=False), encoding="utf-8")
    print(f"wrote {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
