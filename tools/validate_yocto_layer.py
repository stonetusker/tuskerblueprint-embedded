#!/usr/bin/env python3
from pathlib import Path

root = Path(__file__).resolve().parents[1]
required = [
    'meta-sensornode/conf/layer.conf',
    'meta-sensornode/conf/distro/sensornode.conf',
    'meta-sensornode/recipes-core/images/sensornode-image-ci.bb',
    'meta-sensornode/recipes-core/images/sensornode-image-release.bb',
    'meta-sensornode/recipes-core/packagegroups/packagegroup-sensornode.bb',
    'meta-sensornode/recipes-sensornode/sensornode-app/sensornode-app_0.1.0.bb',
    'meta-sensornode/lib/oeqa/runtime/cases/sensornode.py',
    'kas/base.yml',
    'kas/ci.yml',
    'kas/mender.yml',
]
missing = [p for p in required if not (root / p).is_file()]
if missing:
    raise SystemExit('missing Yocto assets: ' + ', '.join(missing))

layer = (root / 'meta-sensornode/conf/layer.conf').read_text()
if 'LAYERSERIES_COMPAT_sensornode = "scarthgap"' not in layer:
    raise SystemExit('meta-sensornode does not declare Scarthgap compatibility')

mender = (root / 'kas/mender.yml').read_text()
for text in ['meta-mender-core', 'meta-mender-qemu', 'INHERIT += "mender-full"']:
    if text not in mender:
        raise SystemExit(f'kas/mender.yml missing required integration: {text}')

release = (root / 'meta-sensornode/recipes-core/sensornode-release/sensornode-release.bb').read_text()
if 'CONFFILES' in release:
    raise SystemExit('immutable release identity must not be marked as a mutable conffile')

service = (root / 'meta-sensornode/recipes-sensornode/sensornode-app/files/sensornode.service').read_text()
for hardening in ['NoNewPrivileges=true', 'ProtectSystem=strict', 'CapabilityBoundingSet=']:
    if hardening not in service:
        raise SystemExit(f'sensornode.service missing hardening: {hardening}')

print('validated Yocto layer structure, Mender integration contract, and release identity policy')
