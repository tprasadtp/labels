WATCHTOWER_BASE := $(strip $(patsubst %/, %, $(dir $(realpath $(firstword $(MAKEFILE_LIST))))))

# Set Help and basic stuff
include $(WATCHTOWER_BASE)/make/base.mk

# Name of the project and docker image
NAME  := labels

# OCI Metadata
IMAGE_TITLE             := Labels
IMAGE_DESC              := CLI app for managing GitHub labels
IMAGE_URL               := https://hub.docker.com/r/tprasadtp/labels
IMAGE_SOURCE            := https://github.com/tprasadtp/labels
IMAGE_LICENSES          := MIT
IMAGE_DOCUMENTATION     := https://github.com/tprasadtp/mkdocs-material

# docker tag related stuff
DOCKER_TARGET      := release
UPSTREAM_PRESENT   := true
UPSTREAM_AUTHOR    := https://github.com/hackebrot
UPSTREAM_URL       := https://github.com/hackebrot/labels

VERSION            := $(shell python3 "$(WATCHTOWER_BASE)/scripts/getversion.py")

include $(WATCHTOWER_BASE)/make/docker.mk

.PHONY: test
test: ## Test and Lint
	@echo -e "\033[92m➜ $@ \033[0m"
	# @pytest --cov=src/labels -v --cov-report=xml
	@pytest -v $(WATCHTOWER_BASE)

.PHONY: mypy
mypy: ## Run mypy on files
	@echo -e "\033[92m➜ $@ \033[0m"
	@mypy $(WATCHTOWER_BASE)/src/labels

.PHONY: flake8
flake8: ## Run flake8
	@echo -e "\033[92m➜ $@ \033[0m"
	@flake8 $(WATCHTOWER_BASE)/

.PHONY: shellcheck
shellcheck: ## Shellcheck
	@echo -e "\033[92m➜ $@ \033[0m"
	shellcheck $(WATCHTOWER_BASE)/entrypoint.sh

.PHONY: lint
lint: black-lint isort-lint flake8 mypy docker-lint ## lint everything (black, isort, flake8, mypy, docker)

.PHONY: dist
dist: ## build dist
	@echo -e "\033[92m➜ $@ \033[0m"
	@poetry build

.PHONY: clean
clean: ## Clean
	@echo -e "\033[92m➜ $@ \033[0m"
	@echo -e "\033[95m * mypy\033[0m"
	@rm -rf .mypy_cache
	@echo -e "\033[95m * pytest\033[0m"
	@rm -rf .pytest_cache .coverage
	@echo -e "\033[95m * dist\033[0m"
	@rm -rf dist
	@echo -e "\033[95m * pycache\033[0m"
	@find . -name '*.pyc' -delete
	@find . -name '__pycache__' -type d | xargs rm -fr

.PHONY: install
install: ## Same as poetry install with fixes
	@echo -e "\033[92m➜ $@ \033[0m"
	@poetry install
