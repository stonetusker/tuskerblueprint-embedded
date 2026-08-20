#!/usr/bin/env python3
from __future__ import annotations

import re
import sys
from pathlib import Path


def main() -> int:
    root = Path('.').resolve()
    failures = []

    prohibited_files = []
    for pattern in ('*.pem', '*.key', 'id_rsa', 'id_ed25519'):
        prohibited_files.extend(p for p in root.rglob(pattern) if '.git' not in p.parts)
    if prohibited_files:
        failures.append('prohibited credential-like files: ' + ', '.join(str(p.relative_to(root)) for p in prohibited_files))

    jenkins = (root / 'ci/jenkins/Jenkinsfile').read_text(encoding='utf-8')
    for expected in ('input message:', 'submitter:', "agent { label 'yocto-vps8' }"):
        if expected not in jenkins:
            failures.append(f'Jenkinsfile missing governance control: {expected}')

    promotion = (root / '.github/workflows/promote-mender.yml').read_text(encoding='utf-8')
    if 'environment: firmware-production' not in promotion:
        failures.append('Mender promotion lacks protected environment')

    release = (root / '.github/workflows/release-candidate.yml').read_text(encoding='utf-8')
    if 'environment: firmware-signing' not in release or 'runs-on: [self-hosted, linux, release]' not in release:
        failures.append('release signing is not isolated on the protected release runner')

    pr = (root / '.github/workflows/pull-request.yml').read_text(encoding='utf-8')
    if 'pull_request_target' in pr:
        failures.append('pull_request_target is prohibited')
    if '/srv/yocto-pr-cache/' not in pr:
        failures.append('pull-request Yocto job lacks isolated cache')

    required_yocto = [
        'meta-sensornode/conf/layer.conf',
        'meta-sensornode/conf/distro/sensornode.conf',
        'meta-sensornode/recipes-core/images/sensornode-image-ci.bb',
        'meta-sensornode/recipes-core/images/sensornode-image-release.bb',
        'meta-sensornode/recipes-sensornode/sensornode-app/sensornode-app_0.1.0.bb',
        'meta-sensornode/lib/oeqa/runtime/cases/sensornode.py',
    ]
    for rel in required_yocto:
        if not (root / rel).is_file():
            failures.append(f'missing required Yocto layer asset: {rel}')

    scripts = (root / 'scripts/build-image.sh').read_text(encoding='utf-8')
    if '/work/cache' not in scripts:
        failures.append('builder cache is not mounted at the path used by kas')

    mender_readme = (root / 'infra/compose/mender/README.md').read_text(encoding='utf-8')
    if 'version-specific' not in mender_readme:
        failures.append('Mender server compatibility boundary is not documented')

    if failures:
        print('\n'.join(failures), file=sys.stderr)
        return 1
    print('validated repository security and architecture policy controls')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
