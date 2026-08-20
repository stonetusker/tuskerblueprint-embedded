SHELL := /usr/bin/env bash
VERSION ?= 0.1.0
GIT_COMMIT ?= $(shell git rev-parse --short HEAD 2>/dev/null || echo unknown)
BUILD_TIME ?= $(shell date -u +%Y-%m-%dT%H:%M:%SZ)
LDFLAGS := -s -w -X main.version=$(VERSION) -X main.gitCommit=$(GIT_COMMIT) -X main.buildTime=$(BUILD_TIME)

.PHONY: fmt test build run
fmt:
	@test -z "$$(gofmt -l .)"
test: fmt
	go test ./...
build:
	CGO_ENABLED=0 go build -trimpath -ldflags '$(LDFLAGS)' -o ../../bin/sensornode ./cmd/sensornode
run:
	go run ./cmd/sensornode --listen :8080
