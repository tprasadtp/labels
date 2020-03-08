WATCHTOWER_BASE := $(strip $(patsubst %/, %, $(dir $(realpath $(firstword $(MAKEFILE_LIST))))))

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

# BEGIN-BASE-TEMPLATE

# Set default goal to help, if not set already
.DEFAULT_GOAL ?= help

# Set the shell
SHELL := /bin/bash

# SEMVER_REGEX := ^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$

.PHONY: help
help: ## This help dialog.
	@IFS=$$'\n' ; \
    help_lines=(`fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##/:/' | sort -u`); \
	printf "%-32s %s\n" " Target " "    Help " ; \
    printf "%-32s %s\n" "--------" "------------" ; \
    for help_line in $${help_lines[@]}; do \
        IFS=$$':' ; \
        help_split=($$help_line) ; \
        help_command="$$(echo $${help_split[0]} | sed -e 's/^ *//' -e 's/ *$$//')" ; \
        help_info="$$(echo $${help_split[2]} | sed -e 's/^ *//' -e 's/ *$$//')" ; \
        printf '\033[92m'; \
        printf "↠ %-30s %s" $$help_command ; \
        printf '\033[0m'; \
        printf "%s\n" $$help_info; \
    done

# END-BASE-TEMPLATE

# Docker
include docker.mk

.PHONY: isort
isort: ## Run isort on all files
	@echo -e "\033[92m➜ $@ \033[0m"
	@isort --recursive --atomic $(WATCHTOWER_BASE)

.PHONY: isort-lint
isort-lint: ## Check isort on all files
	@echo -e "\033[92m➜ $@ \033[0m"
	@isort --recursive --check-only $(WATCHTOWER_BASE)

.PHONY: black
black: ## Black formatter
	@echo -e "\033[92m➜ $@ \033[0m"
	@black $(WATCHTOWER_BASE)

.PHONY: black-lint
black-lint: ## Lint with Black
	@echo -e "\033[92m➜ $@ \033[0m"
	@black --check $(WATCHTOWER_BASE)

.PHONY: fmt
fmt: black isort ## Formatting using black  and isort (in that order)

.PHONY: fmt-lint
fmt-lint: black-lint isort-lint ## Lint with formatters


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
