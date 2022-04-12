SHELL=/bin/bash -o pipefail

REGISTRY ?= kubedb
BIN      := pgbouncer
IMAGE    := $(REGISTRY)/$(BIN)
TAG      := $(shell git describe --exact-match --abbrev=0 2>/dev/null || echo "1.17.0")

DOCKER_PLATFORMS := linux/amd64 linux/arm64
BIN_PLATFORMS    := $(DOCKER_PLATFORMS) windows/amd64 darwin/amd64 darwin/arm64
PLATFORM         ?= $(firstword $(BIN_PLATFORMS))
VERSION          = $(TAG)_$(subst /,_,$(PLATFORM))


USER_FSL_PLATFORM ?=
DEFAULT_FSL_PLATFORM ?= linux/arm64
FSL_PLATFORM ?= $(shell if [ ! -z $(USER_FSL_PLATFORM) ]; then echo $(USER_FSL_PLATFORM)/; fi)

.PHONY: push
push: container
	docker push $(IMAGE):$(TAG)

.PHONY: container
container:
	@echo "container: $(IMAGE):$(TAG)"                           \
	sed                                                  \
	    -e 's|{FSL_PLATFORM}|$(FSL_PLATFORM)|g'               \
	# ref: https://superuser.com/a/842705
	tar -czh . | docker buildx build --platform $(PLATFORM) --load --pull -t $(IMAGE):$(TAG) -f Dockerfile -
	#docker build -t $(IMAGE):$(TAG) .
	@echo

.PHONY: version
version:
	@echo ::set-output name=version::$(TAG)
