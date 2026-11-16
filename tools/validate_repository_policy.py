#!/usr/bin/env python3
from __future__ import annotations

import re
import sys
from pathlib import Path

from repo_files import repo_files


def main() -> int:
    root = Path('.').resolve()
    failures = []

    def public_key_only(path: Path) -> bool:
        # A public verification key (for example mender/keys/*.pem) is allowed.
        text = path.read_text(encoding='utf-8', errors='replace')
        return 'BEGIN PUBLIC KEY' in text and 'PRIVATE' not in text

    prohibited_files = [p for p in repo_files(root)
                        if (p.suffix == '.key' or p.name in {'id_rsa', 'id_ed25519'})
                        or (p.suffix == '.pem' and not public_key_only(p))]
    if prohibited_files:
        failures.append('prohibited credential-like files: ' + ', '.join(str(p.relative_to(root)) for p in prohibited_files))

    jenkins = (root / 'ci/jenkins/Jenkinsfile').read_text(encoding='utf-8')
    for expected in ('input message:', 'submitter:', "agent { label 'yocto-vps8' }"):
        if expected not in jenkins:
            failures.append(f'Jenkinsfile missing governance control: {expected}')

    promotion = (root / 'ci/jenkins/pipelines/promote-mender.Jenkinsfile').read_text(encoding='utf-8')
    if "submitter: 'firmware-production-approvers'" not in promotion:
        failures.append('Mender promotion lacks a production approval gate')

    release = (root / 'ci/jenkins/pipelines/release-candidate.Jenkinsfile').read_text(encoding='utf-8')
    if "submitter: 'firmware-signing-approvers'" not in release or "agent { label 'firmware-release' }" not in release:
        failures.append('release signing is not isolated on the approved firmware-release agent')

    ci = (root / 'ci/jenkins/pipelines/ci.Jenkinsfile').read_text(encoding='utf-8')
    if 'yocto-branch-cache' not in ci:
        failures.append('branch Yocto builds lack an isolated cache')

    if any(p.is_file() for p in (root / '.github/workflows').glob('*')):
        failures.append('GitHub Actions workflows are not used; Jenkins is the only CI/CD orchestrator')

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
