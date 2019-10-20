# Set the shell
SHELL := /bin/bash
NAME := labels
VERSION := $(shell git tag -l --points-at HEAD)
export PYTHONPATH :=$(CURDIR)/src

DOCKER_USER := tprasadtp
.PHONY: docker
docker: ## Create docker image from the Dockerfile.
	@DOCKER_BUILDKIT=0 docker build --rm --force-rm -t $(DOCKER_USER)/$(NAME) -f Dockerfile.user .
	@docker tag $(DOCKER_USER)/$(NAME) docker.pkg.github.com/$(DOCKER_USER)/$(NAME)/$(NAME):latest
	@if ! [ -z $(VERSION) ]; then \
		echo -e "\e[92mCommit is Tagggd with :: $(VERSION)\e[39m"; \
		docker tag docker.pkg.github.com/$(DOCKER_USER)/$(NAME)/action:$(VERSION); \
		docker tag $(DOCKER_USER)/$(NAME) $(DOCKER_USER)/$(NAME):$(VERSION); \
	else \
	echo -e "\e[92mNot a tagged commit, skip version tags.\e[39m"; \
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


.PHONY: docker-push
docker-push: ## Push docker image to GitHub and DockerHub.
	@echo "+ $@"
	@docker push $(DOCKER_USER)/$(NAME):latest
	@docker push docker.pkg.github.com/$(DOCKER_USER)/$(NAME)/$(NAME):latest
	@if ! [ -z $(VERSION) ]; then \
		echo -e "\e[92mCommit is Tagggd with :: $(VERSION)\e[39m"; \
		docker push docker.pkg.github.com/$(DOCKER_USER)/$(NAME)/$(NAME):$(VERSION); \
		docker push $(DOCKER_USER)/$(NAME):$(VERSION); \
	else \
		echo -e "\e[92mNot a tagged commit, skip version tags.\e[39m"; \
	fi

.PHONY: action-docker
action-docker: ## Create GitHub action docker image.
	@DOCKER_BUILDKIT=0 docker build --rm --force-rm -t $(DOCKER_USER)/$(NAME)-action -f Dockerfile .
	@docker tag $(DOCKER_USER)/$(NAME)-action docker.pkg.github.com/$(DOCKER_USER)/$(NAME)/action:latest
	@if ! [ -z $(VERSION) ]; then \
		docker tag $(DOCKER_USER)/$(NAME)-action docker.pkg.github.com/$(DOCKER_USER)/$(NAME)/action:$(VERSION); \
	else \
		echo -e "\e[92mNot a tagged commit, skip version tags.\e[39m"; \
	fi

.PHONY: action-docker-push
action-docker-push: ## Push action docker image to GitHub
	@echo "+ $@"
	@docker push docker.pkg.github.com/$(DOCKER_USER)/$(NAME)/action:latest
	@if ! [ -z $(VERSION) ]; then \
	@docker push docker.pkg.github.com/$(DOCKER_USER)/$(NAME)/action:$(VERSION); \
	else \
		echo -e "\e[92mNot a tagged commit, skip version tags.\e[39m"; \
	fi

.PHONY: test
test: ## Test and Lint
	@echo -e "* \e[92mFlake8\e[39m"
	@flake8 src/
	@echo -e "* \e[92mmypy\e[39m"
	@mypy src/
	@echo -e "* \e[92mpytest\e[39m"
	@pytest -v


# Python Stuff
.PHONY: requirements
requirements: ## Generate requirements{dev}.txt and update setup.py
	@echo "+$@"
	@pipenv_to_requirements
	@python3 sync-setup.py
	@python3 sync-setup.py --flit

.PHONY: dist
dist: ## build dist
	@python setup.py sdist bdist_wheel

.PHONY: help
help: ## This help dialog.
	@IFS=$$'\n' ; \
    help_lines=(`fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##/:/'`); \
    printf "%-30s %s\n" "--------" "------------" ; \
	printf "%-30s %s\n" " Target " "    Help " ; \
    printf "%-30s %s\n" "--------" "------------" ; \
    for help_line in $${help_lines[@]}; do \
        IFS=$$':' ; \
        help_split=($$help_line) ; \
        help_command=`echo $${help_split[0]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
        help_info=`echo $${help_split[2]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
        printf '\033[92m'; \
        printf "%-30s %s" $$help_command ; \
        printf '\033[0m'; \
        printf "%s\n" $$help_info; \
    done
