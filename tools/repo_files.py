"""List the repository's own files for the validators.

CI workspaces also contain the kas-fetched layers (poky, meta-openembedded,
meta-mender), the build tree, caches and artifacts. Those are third-party or
generated and must not be validated against this project's policies. Git already
knows what belongs to the repository: tracked files plus new files that are not
ignored. Without Git, fall back to a walk that skips the known generated trees.
"""
from __future__ import annotations

import subprocess
from pathlib import Path

GENERATED = {'.git', '.venv', 'venv', '.pytest_cache', '__pycache__', 'build', 'cache', 'cache.old',
             'artifacts', 'poky', 'meta-openembedded', 'meta-mender', 'node_modules'}


def repo_files(root: str | Path = '.', suffixes: tuple[str, ...] | None = None,
               names: tuple[str, ...] | None = None) -> list[Path]:
    root = Path(root).resolve()
    try:
        out = subprocess.run(['git', '-C', str(root), 'ls-files', '-z', '--cached', '--others', '--exclude-standard'],
                             capture_output=True, check=True).stdout.decode('utf-8')
        paths = [root / p for p in out.split('\0') if p]
    except (OSError, subprocess.CalledProcessError):
        paths = [p for p in root.rglob('*')
                 if not any(part in GENERATED for part in p.relative_to(root).parts[:-1])]
    result = []
    for p in paths:
        if not p.is_file():
            continue  # deleted in the working tree, or a submodule directory
        if suffixes is None and names is None:
            result.append(p)
        elif (suffixes and p.suffix in suffixes) or (names and any(p.name.startswith(n) for n in names)):
            result.append(p)
    return sorted(result)
