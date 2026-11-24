#!/usr/bin/env python3
"""Validate the Jenkins pipelines and job definitions against the CI/CD policy.

Jenkins is the only CI/CD orchestrator; GitHub is only the Git host. The checks
enforce the release boundaries that the pipelines are built around:

* every Jenkinsfile has a job definition and every job definition points at an
  existing Jenkinsfile;
* only the release-candidate and promotion pipelines may sign or deploy, and they
  do so on the isolated `firmware-release` agent after a named approval group;
* the trusted cache is written only from main; other branches use isolated caches;
* the diagnostic pipeline keeps its human approval before a rebuild;
* no GitHub Actions workflow remains.
"""
from __future__ import annotations

import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path('.')
JENKINS = ROOT / 'ci/jenkins'
PIPELINES = {
    'diagnostic': JENKINS / 'Jenkinsfile',
    'ci': JENKINS / 'pipelines/ci.Jenkinsfile',
    'nightly': JENKINS / 'pipelines/nightly.Jenkinsfile',
    'release': JENKINS / 'pipelines/release-candidate.Jenkinsfile',
    'promote': JENKINS / 'pipelines/promote-mender.Jenkinsfile',
}
RELEASE_ONLY = ('sign-artifact.sh', 'upload-mender-artifact.sh', 'create-mender-deployment.sh',
                'publish_candidate.py', 'mender-signing', 'mender-access-token',
                'push-release-tag.sh', 'github-release-tag')


def jenkinsfile_parameters(text: str) -> list[str]:
    """Names declared in a Declarative Pipeline `parameters { ... }` block."""
    block = re.search(r"\bparameters\s*\{(.*?)\n\s*\}", text, re.S)
    if not block:
        return []
    return re.findall(r"\b(?:string|booleanParam|choice|text|password)\(\s*name:\s*'([A-Za-z0-9_]+)'", block.group(1))


def code_lines(text: str) -> str:
    """Drop // comment lines so policy words in comments do not count."""
    return '\n'.join(line for line in text.splitlines() if not line.lstrip().startswith('//'))


def main() -> int:
    failures: list[str] = []
    texts: dict[str, str] = {}
    for key, path in PIPELINES.items():
        if not path.is_file():
            failures.append(f'missing pipeline {path}')
            continue
        text = code_lines(path.read_text(encoding='utf-8'))
        texts[key] = text
        if 'pipeline {' not in text or 'agent' not in text:
            failures.append(f'{path}: not a declarative pipeline with an agent')
        if 'timeout(' not in text:
            failures.append(f'{path}: missing a pipeline timeout')

    # Job definitions <-> Jenkinsfiles
    referenced = set()
    templates = sorted((JENKINS / 'job-config').glob('*.xml.template'))
    for template in templates:
        try:
            tree = ET.parse(template)
        except ET.ParseError as exc:
            failures.append(f'{template}: invalid XML ({exc})')
            continue
        script = tree.find('.//scriptPath')
        if script is None or not (script.text or '').strip():
            failures.append(f'{template}: no scriptPath')
            continue
        target = ROOT / script.text.strip()
        referenced.add(target.resolve())
        if not target.is_file():
            failures.append(f'{template}: scriptPath {script.text.strip()} does not exist')
            continue
        # A pipeline job only learns parameters declared in its Jenkinsfile after the first
        # run, so the job definition must declare them too (multibranch jobs are exempt).
        if 'MultiBranch' not in tree.getroot().tag:
            declared = jenkinsfile_parameters(target.read_text(encoding='utf-8'))
            defined = [n.text for n in tree.findall('.//parameterDefinitions/*/name')]
            if sorted(declared) != sorted(defined):
                failures.append(f'{template}: parameters {sorted(defined)} do not match {script.text.strip()} {sorted(declared)}')
    for path in PIPELINES.values():
        if path.is_file() and path.resolve() not in referenced:
            failures.append(f'{path}: no job definition in ci/jenkins/job-config references it')

    # Release authority stays in the two release pipelines
    for key in ('diagnostic', 'ci', 'nightly'):
        for word in RELEASE_ONLY:
            if word in texts.get(key, ''):
                failures.append(f'{PIPELINES[key]}: {word} is reserved for the release pipelines')

    release = texts.get('release', '')
    for needed in ("submitter: 'firmware-signing-approvers'", "label 'firmware-release'",
                   'sign-artifact.sh', 'publish_candidate.py', 'merge-base --is-ancestor',
                   'validate_source_lock.py', 'run-release-qemu-tests.sh', 'generate-sbom.sh'):
        if needed not in release:
            failures.append(f'release-candidate pipeline missing control: {needed}')
    if 'push-release-tag.sh' not in release or release.find('push-release-tag.sh') < release.find('publish_candidate.py'):
        failures.append('release-candidate pipeline must push the release tag only after publishing the candidate')
    if release.find("label 'firmware-release'") < release.find("submitter: 'firmware-signing-approvers'"):
        failures.append('release-candidate pipeline must approve before it reaches the firmware-release agent')

    promote = texts.get('promote', '')
    for needed in ("submitter: 'firmware-production-approvers'", "label 'firmware-release'",
                   'fetch_candidate.py', 'EXPECTED_SHA256', 'create-mender-deployment.sh'):
        if needed not in promote:
            failures.append(f'promote-mender pipeline missing control: {needed}')

    ci = texts.get('ci', '')
    if 'yocto-branch-cache' not in ci:
        failures.append('ci pipeline: non-main branches must use an isolated cache')
    publish = ci.find("stage('Publish trusted cache')")
    if publish < 0 or "when { branch 'main' }" not in ci[publish:publish + 200]:
        failures.append('ci pipeline: the trusted cache may only be published from main')

    diagnostic = texts.get('diagnostic', '')
    for needed in ('input message:', 'submitter:', "agent { label 'yocto-vps8' }"):
        if needed not in diagnostic:
            failures.append(f'diagnostic pipeline missing governance control: {needed}')

    workflows = [p for p in (ROOT / '.github/workflows').glob('*') if p.is_file()]
    if workflows:
        failures.append('GitHub Actions workflows are not used; remove: ' + ', '.join(str(p) for p in workflows))

    if failures:
        print('\n'.join(failures), file=sys.stderr)
        return 1
    print(f'validated policy in {len(texts)} Jenkins pipelines and {len(templates)} job definitions')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
