SHELL         := /bin/bash
VERSION       ?= 0.0.1
BUILD         := $(shell date -u +%FT%T%z)
GIT_HASH      := $(shell git rev-parse HEAD)
GIT_REPO      := $(shell git config --get remote.origin.url)
BUILDKITE_COMMIT ?= $(GIT_HASH)
GIT_COMMIT    ?= $(GIT_HASH)
IMAGE_REPOSITORY := 896069866492.dkr.ecr.eu-west-1.amazonaws.com/responsible
ifneq (,$(wildcard env/${K8S_NAMESPACE}_app.yaml))
	ENV_SPECIFIC_CONFIG := -f env/${K8S_NAMESPACE}_app.yaml
endif

export IMAGE_REPOSITORY
export GIT_HASH
export BUILDKITE_COMMIT
export GIT_COMMIT


.PHONY: build
build:
	docker build -t ${IMAGE_REPOSITORY}:${BUILDKITE_COMMIT} .

.PHONY: publish
publish: build
	docker push ${IMAGE_REPOSITORY}:${BUILDKITE_COMMIT}

.PHONY: up
up:
	docker-compose up -d

.PHONY: down
down:
	docker-compose down -v --remove-orphans

.PHONY: clean
clean: down

.PHONY: test-up
test-up:
	docker-compose -f docker-compose.yml up -d

.PHONY: test
test: test-up
	docker-compose exec app .buildkite/test.sh

.PHONY: build-gem
build-gem: up
	docker-compose exec app gem build responsible.gemspec

.PHONY: publish-gem
publish-gem: build-gem
	docker-compose exec app gem inabox responsible-*.gem --host http://gems.reevoocloud.com
