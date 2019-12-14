# Set the shell
SHELL := /bin/bash
NAME := labels
VERSION := $(shell git tag -l --points-at HEAD)
export PYTHONPATH :=$(CURDIR)/src

DOCKER_USER := tprasadtp
.PHONY: docker
docker: ## Create docker image from the Dockerfile.
	@DOCKER_BUILDKIT=0 docker build --rm --force-rm -t $(NAME) -f Dockerfile.user .
	@if ! [ -z $(VERSION) ]; then \
		echo -e "\e[92mCommit is Tagggd with :: $(VERSION)\e[39m"; \
		docker tag $(NAME) docker.pkg.github.com/$(DOCKER_USER)/$(NAME)/action:$(VERSION); \
		docker tag $(NAME) $(DOCKER_USER)/$(NAME):$(VERSION); \
	else \
		echo -e "\e[92mNot a tagged commit, skipping version tags.\e[39m"; \
		docker tag $(NAME) docker.pkg.github.com/$(DOCKER_USER)/$(NAME)/$(NAME):latest; \
		docker tag $(NAME) $(DOCKER_USER):latest; \
	fi

# User github docker image by default
.PHONY: run-fetch
run-fetch: ## Fetch labels(docker) Eg. `make run-fetch REPO=repo OWNER=ghusername`
	@echo "+ $@"
	@echo "OWNER : $(OWNER), REPO : $(REPO)"
	@touch -a .github/labels.toml
	@docker run -it -e LABELS_USERNAME=${GITHUB_USERNAME} \
	 	-e LABELS_TOKEN=${GITHUB_TOKEN} \
		-v $(CURDIR)/.github/labels.toml:/home/user/labels.toml:rw \
		docker.pkg.github.com/tprasadtp/labels/labels:latest \
		fetch -r $(REPO) -o $(OWNER)

.PHONY: docker-push-hub
docker-push-hub: ## Push docker image to DockerHub.
	@echo "+ $@"
	@if ! [ -z $(VERSION) ]; then \
		echo -e "\e[92mCommit is Tagggd with :: $(VERSION)\e[39m"; \
		docker push $(DOCKER_USER)/$(NAME):$(VERSION); \
	else \
		echo -e "\e[92mNot a tagged commit, tag latest.\e[39m"; \
		docker push $(DOCKER_USER)/$(NAME):latest; \
	fi

.PHONY: docker-push-github
docker-push-github: ## Push docker image to GitHub.
	@echo "+ $@"
	@if ! [ -z $(VERSION) ]; then \
		echo -e "\e[92mCommit is Tagggd with :: $(VERSION)\e[39m"; \
		docker push docker.pkg.github.com/$(DOCKER_USER)/$(NAME)/$(NAME):$(VERSION); \
	else \
		echo -e "\e[92mNot a tagged commit, tag latest.\e[39m"; \
		docker push docker.pkg.github.com/$(DOCKER_USER)/$(NAME)/$(NAME):latest; \
	fi

.PHONY: docker-push
docker-push: docker-push-github docker-push-hub ## Push dockr images to GitHub and DockerHub

.PHONY: action-docker
action-docker: ## Create GitHub action docker image.
	@DOCKER_BUILDKIT=0 docker build --rm --force-rm -t $(NAME)-action -f Dockerfile .
	@if ! [ -z $(VERSION) ]; then \
		docker tag $(NAME)-action docker.pkg.github.com/$(DOCKER_USER)/$(NAME)/action:$(VERSION); \
	else \
		echo -e "\e[92mNot a tagged commit, tag latest.\e[39m"; \
		docker tag $(NAME)-action docker.pkg.github.com/$(DOCKER_USER)/$(NAME)/action:latest; \
	fi

.PHONY: action-docker-push
action-docker-push: ## Push action docker image to GitHub
	@echo "+ $@"
	@if ! [ -z $(VERSION) ]; then \
		docker push docker.pkg.github.com/$(DOCKER_USER)/$(NAME)/action:$(VERSION); \
	else \
		echo -e "\e[92mNot a tagged commit, push latest tag.\e[39m"; \
		docker push docker.pkg.github.com/$(DOCKER_USER)/$(NAME)/action:latest; \
	fi


.PHONY: test
test: ## Test and Lint
	@echo -e "\033[92m➜ $@ \033[0m"
	@echo -e "\033[95m * pytest\033[0m"
	@pytest --cov=src/labels -v --cov-report=xml

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

.PHONY: safety-check
safety-check: ## Check Package safety
	@echo -e "\033[92m➜ $@ \033[0m"
	@echo -e "\033[95m * Checking Environemnt...\033[0m"
	@safety check

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
