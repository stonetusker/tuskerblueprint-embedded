#!/usr/bin/env python3
from __future__ import annotations

import argparse
import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path


def digest(path: Path) -> str:
    value = hashlib.sha256()
    with path.open('rb') as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b''):
            value.update(block)
    return value.hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument('--product', default='SensorNode')
    parser.add_argument('--version', default='development')
    parser.add_argument('--git-commit', default='unknown')
    parser.add_argument('--build-number', default='local')
    parser.add_argument('--machine', default='qemuarm64')
    parser.add_argument('--distro', default='sensornode')
    parser.add_argument('--image', default='sensornode-image-ci')
    parser.add_argument('--builder', default='unknown')
    parser.add_argument('--artifact-root', default='artifacts')
    parser.add_argument('--output', required=True)
    args = parser.parse_args()

    root = Path(args.artifact_root)
    artifacts = []
    if root.exists():
        for path in sorted(root.rglob('*')):
            if path.is_file() and path.resolve() != Path(args.output).resolve() and path.stat().st_size < 5 * 1024**3:
                artifacts.append({'path': str(path.relative_to(root)), 'size_bytes': path.stat().st_size, 'sha256': digest(path)})

    manifest = {
        'schema_version': 1,
        'product': args.product,
        'version': args.version,
        'git_commit': args.git_commit,
        'build_number': args.build_number,
        'machine': args.machine,
        'distro': args.distro,
        'image': args.image,
        'builder': args.builder,
        'generated_at': datetime.now(timezone.utc).isoformat(),
        'artifacts': artifacts,
    }
    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(manifest, indent=2, sort_keys=True) + '\n', encoding='utf-8')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
