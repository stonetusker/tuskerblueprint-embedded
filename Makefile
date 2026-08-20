SHELL := /usr/bin/env bash
.DEFAULT_GOAL := help

PROJECT_ROOT := $(CURDIR)
BUILD_DIR ?= $(PROJECT_ROOT)/build
KAS_FILE ?= kas/ci.yml
IMAGE ?= sensornode-image-ci

.PHONY: help bootstrap doctor setup source-lock source-lock-check builder-image validate docs-check app-fmt app-test app-build shell-check python-check yaml-check \
        yocto-build qemu-test benchmark release-manifest review clean

help:
	@printf '%s\n' \
	  'bootstrap         Prepare an Ubuntu 24.x host (requires sudo)' \
	  'doctor            Validate Ubuntu 24 host readiness' \
	  'setup             Install local Python validation dependencies' \
	  'source-lock       Resolve Yocto/Mender branches to immutable commits' \
	  'source-lock-check Validate committed immutable source lock' \
	  'builder-image     Build the Yocto builder container' \
	  'validate          Run repository validation suite' \
	  'docs-check        Validate controlled Markdown and traceability' \
	  'app-test          Run SensorNode Go tests' \
	  'app-build         Build the SensorNode application' \
	  'yocto-build       Build the configured Yocto image with kas' \
	  'qemu-test         Run Yocto testimage/OEQA tests' \
	  'benchmark         Run the controlled clean/cache benchmark' \
	  'release-manifest  Generate release manifest from build outputs' \
	  'review            Run principal-engineer repository review' \
	  'clean             Remove local generated outputs'

bootstrap:
	scripts/bootstrap-ubuntu24.sh

doctor:
	scripts/doctor-ubuntu24.sh

source-lock: setup
	.venv/bin/python tools/lock_sources.py --config kas/base.yml --config kas/mender.yml --output kas/source-lock.yml

source-lock-check:
	python3 tools/validate_source_lock.py kas/source-lock.yml --require-mender

builder-image:
	scripts/build-builder-image.sh

setup:
	python3 -m venv .venv
	.venv/bin/pip install -r tools/requirements.txt

validate: docs-check app-test app-integration python-check yaml-check workflow-check policy-check shell-check review

docs-check:
	python3 tools/validate_specs.py
	python3 tools/validate_traceability.py
	python3 tools/validate_markdown_links.py

app-fmt:
	cd app/sensornode && test -z "$$(gofmt -l .)"

app-test: app-fmt
	cd app/sensornode && go test ./...

app-integration:
	scripts/test-sensornode-integration.sh

app-build:
	cd app/sensornode && CGO_ENABLED=0 go build -trimpath -o ../../bin/sensornode ./cmd/sensornode

python-check:
	python3 -m compileall -q tools tests

yaml-check:
	python3 tools/validate_yaml.py
	python3 tools/validate_yocto_layer.py
	python3 tools/validate_ubuntu24_portability.py

workflow-check:
	python3 tools/validate_workflows.py

policy-check:
	python3 tools/validate_repository_policy.py

shell-check:
	bash scripts/check-shell-syntax.sh

yocto-build:
	KAS_FILE=$(KAS_FILE) IMAGE=$(IMAGE) scripts/build-image.sh

qemu-test:
	KAS_FILE=kas/ci.yml IMAGE=sensornode-image-ci scripts/run-qemu-tests.sh

benchmark:
	scripts/benchmark-build.sh

release-manifest:
	python3 tools/generate_release_manifest.py --output artifacts/release-manifest.json

review:
	python3 tools/review_repository.py --root . --report REVIEW_REPORT.md

clean:
	rm -rf bin artifacts .pytest_cache __pycache__ tests/**/__pycache__ tools/__pycache__
