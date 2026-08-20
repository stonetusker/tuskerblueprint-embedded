#!/usr/bin/env python3
from pathlib import Path
import re

root = Path(__file__).resolve().parents[1]
required = [
    'scripts/bootstrap-ubuntu24.sh',
    'scripts/doctor-ubuntu24.sh',
    'scripts/build-builder-image.sh',
    'config/project.env.example',
    'tools/lock_sources.py',
    'tools/validate_source_lock.py',
    'containers/yocto-builder/Dockerfile',
]
missing = [p for p in required if not (root / p).is_file()]
if missing:
    raise SystemExit('missing Ubuntu 24 portability assets: ' + ', '.join(missing))

dockerfile = (root / 'containers/yocto-builder/Dockerfile').read_text()
if 'FROM ubuntu:24.04' not in dockerfile:
    raise SystemExit('Yocto builder is not based on Ubuntu 24.04')

for workflow in (root / '.github/workflows').glob('*.yml'):
    text = workflow.read_text()
    if re.search(r'runs-on:\s*\[[^\]]*\bx64\b', text):
        raise SystemExit(f'architecture-specific x64 runner label remains in {workflow.relative_to(root)}')

qemu = (root / 'qemu-fleet/launch/qemu-device.sh').read_text()
if 'hostfwd=tcp:127.0.0.1:' not in qemu:
    raise SystemExit('QEMU forwarded ports are not loopback-bound')
if 'QEMU_ACCEL' not in qemu or 'aarch64' not in qemu:
    raise SystemExit('QEMU launcher lacks architecture-aware acceleration handling')

print('validated Ubuntu 24.x portability assets for x86_64 and aarch64 hosts')
