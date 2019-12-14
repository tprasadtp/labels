# Set the shell
SHELL := /bin/bash
NAME := labels
ifeq ($(GITHUB_ACTIONS),true)
	BRANCH := $(shell echo "$$GITHUB_REF" | cut -d '/' -f 3- | sed -r 's/[\/\*\#]+/-/g' )
else
	BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
endif

VERSION := $(shell python3 scripts/getversion.py )


export PYTHONPATH :=$(CURDIR)/src

# Enable Buidkit if not already set
DOCKER_BUILDKIT ?= 1

DOCKER_USER := tprasadtp

# Prefix for github package registry images
DOCKER_PREFIX_GITHUB := docker.pkg.github.com/$(DOCKER_USER)/$(NAME)


.PHONY: all
all: clean lint test dist docker-lint docker ## clean, lint, test, dist and docker

.PHONY: docker-lint
docker-lint: ## Lint Dockerfiles
	@echo -e "\033[92m➜ $@ \033[0m"
	@echo -e "\033[95m * Linting Dockerfile\033[0m"
	@docker run --rm -v $(CURDIR)/.hadolint.yaml:/.hadolint.yaml:ro -i hadolint/hadolint < Dockerfile
	@echo -e "\033[95m * Linting Dockerfile.user\033[0m"
	@docker run --rm -v $(CURDIR)/.hadolint.yaml:/.hadolint.yaml:ro -i hadolint/hadolint < Dockerfile.user


.PHONY: docker
docker: ## Build docker images (action and user images)
	@echo -e "\033[92m➜ $@ \033[0m"
	@echo -e "\033[95m * Building Action Image\033[0m"
	@DOCKER_BUILDKIT=$(DOCKER_BUILDKIT) docker build -t $(NAME)-action -f Dockerfile .
	@if [ $(BRANCH) == "master" ]; then \
		echo -e "\033[95m * On master add tagging as $(VERSION) \033[0m"; \
		docker tag $(NAME)-action $(DOCKER_PREFIX_GITHUB)/action:latest; \
		docker tag $(NAME)-action $(DOCKER_PREFIX_GITHUB)/action:$(VERSION); \
	else \
		echo -e "\033[95m * Not on master tagging as $(BRANCH).\033[0m"; \
		docker tag $(NAME)-action $(DOCKER_PREFIX_GITHUB)/action:$(BRANCH); \
	fi
	@echo -e "\033[95m * Building User Image\033[0m"
	@DOCKER_BUILDKIT=$(DOCKER_BUILDKIT) docker build -t $(NAME) -f Dockerfile.user .
	@if [ $(BRANCH) == "master" ]; then \
		echo -e "\033[95m * On master add tagging as $(VERSION) \033[0m"; \
		docker tag $(NAME) $(DOCKER_USER)/$(NAME):latest; \
		docker tag $(NAME) $(DOCKER_USER)/$(NAME):$(VERSION); \
		docker tag $(NAME) $(DOCKER_PREFIX_GITHUB)/$(NAME):latest; \
		docker tag $(NAME) $(DOCKER_PREFIX_GITHUB)/$(NAME):$(VERSION); \
	else \
		echo -e "\033[95m * Not on master add tagging as $(BRANCH).\033[0m"; \
		docker tag $(NAME) $(DOCKER_USER)/$(NAME):$(BRANCH); \
		docker tag $(NAME) $(DOCKER_PREFIX_GITHUB)/$(NAME):$(BRANCH); \
	fi

.PHONY: docker-push
docker-push: ## Push docker images (action and user images)
	@echo -e "\033[92m➜ $@ \033[0m"
	@echo -e "\033[95m * Pushing User Image\033[0m"
	@if [ $(BRANCH) == "master" ]; then \
		echo -e "\033[93m   + On master add pushing latest and $(VERSION) to DockerHub\033[0m"; \
		docker push $(DOCKER_USER)/$(NAME):latest; \
		docker push $(DOCKER_USER)/$(NAME):$(VERSION); \
		echo -e "\033[93m   + On master add pushing latest and $(VERSION) to GitHub \033[0m"; \
		docker push $(DOCKER_PREFIX_GITHUB)/$(NAME):latest; \
		docker push $(DOCKER_PREFIX_GITHUB)/$(NAME):$(VERSION); \
	else \
		echo -e "\033[93m   + Not on master and pushing $(BRANCH) to DockerHub.\033[0m"; \
		docker push $(DOCKER_USER)/$(NAME):$(BRANCH); \
		echo -e "\033[93m   + Not on master and pushing $(BRANCH) to GitHub \033[0m"; \
		docker push $(DOCKER_PREFIX_GITHUB)/$(NAME):$(BRANCH); \
	fi
	@echo -e "\033[95m * Pushing Action Image\033[0m"
	@if [ $(BRANCH) == "master" ]; then \
		echo -e "\033[93m   + On master add pushing latest and $(VERSION) \033[0m"; \
		docker push $(DOCKER_PREFIX_GITHUB)/action:latest; \
		docker push $(DOCKER_PREFIX_GITHUB)/action:$(VERSION); \
	else \
		echo -e "\033[93m   + Not on master as pushing $(BRANCH).\033[0m"; \
		docker push $(DOCKER_PREFIX_GITHUB)/action:$(BRANCH); \
	fi

.PHONY: test
test: ## Test and Lint
	@echo -e "\033[92m➜ $@ \033[0m"
	@echo -e "\033[95m * pytest\033[0m"
	# @pytest --cov=src/labels -v --cov-report=xml
	@pytest -v

.PHONY: isort
isort: ## Run isort on all files
	@echo -e "\033[92m➜ $@ \033[0m"
	@echo -e "\033[95m * Running isort...\033[0m"
	@isort --recursive --atomic .

.PHONY: isort-lint
isort-lint: ## Check isort on all files
	@echo -e "\033[92m➜ $@ \033[0m"
	@echo -e "\033[95m * Running isort...\033[0m"
	@isort --recursive --check-only .

.PHONY: mypy
mypy: ## Run mypy on files
	@echo -e "\033[92m➜ $@ \033[0m"
	@echo -e "\033[95m * Running mypy...\033[0m"
	@mypy src

.PHONY: flake8
flake8: ## Run flake8
	@echo -e "\033[92m➜ $@ \033[0m"
	@echo -e "\033[95m * Running flake8...\033[0m"
	@flake8

.PHONY: black
black: ## Black formatter
	@echo -e "\033[92m➜ $@ \033[0m"
	@echo -e "\033[95m * Black Formatting utils...\033[0m"
	@black .

.PHONY: black-lint
black-lint: ## Lint with Black
	@echo -e "\033[92m➜ $@ \033[0m"
	@echo -e "\033[95m Linting utils...\033[0m"
	@black --check .

.PHONY: fmt
fmt: black isort ## Formatting using black  and isort (in that order)

.PHONY: fmt-lint
fmt-lint: black-lint isort-lint ## Lint with formatters

.PHONY: lint
lint: black-lint isort-lint flake8 mypy docker-lint ## lint everything (black, isort, flake8, mypy, docker)

.PHONY: dist
dist: ## build dist
	@echo -e "\033[92m➜ $@ \033[0m"
	@echo -e "\033[95m * mypy\033[0m"
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
	@mkdir -p .venv/lib/python3.6/site-packages
	@touch .venv/lib/python3.6/site-packages/easy-install.pth
	@poetry install

.PHONY: help
help: ## This help dialog.
	@IFS=$$'\n' ; \
    help_lines=(`fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##/:/'`); \
	printf "%-32s %s\n" " Target " "    Help " ; \
    printf "%-32s %s\n" "--------" "------------" ; \
    for help_line in $${help_lines[@]}; do \
        IFS=$$':' ; \
        help_split=($$help_line) ; \
        help_command=`echo $${help_split[0]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
        help_info=`echo $${help_split[2]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
        printf '\033[92m'; \
        printf "➜ %-30s %s" $$help_command ; \
        printf '\033[0m'; \
        printf "%s\n" $$help_info; \
    done
