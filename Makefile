SHELL=/bin/bash -o pipefail

REGISTRY ?= kubedb
BIN      := pgbouncer
IMAGE    := $(REGISTRY)/$(BIN)
TAG      := $(shell git describe --exact-match --abbrev=0 2>/dev/null || echo "")

.PHONY: push
push: container
	docker push $(IMAGE):$(TAG)

.PHONY: container
container:
	docker build -t $(IMAGE):$(TAG) .
