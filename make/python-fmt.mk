
# Directories in which python code should be fmt'd
PYTHON_FMT_DIRS ?= $(WATCHTOWER_BASE)

.PHONY: isort
isort: ## Run isort on all files
	@echo -e "\033[92m➜ $@ \033[0m"
	@isort --recursive --atomic $(PYTHON_FMT_DIRS)

.PHONY: isort-lint
isort-lint: ## Check isort on all files
	@echo -e "\033[92m➜ $@ \033[0m"
	@isort --recursive --check-only $(PYTHON_FMT_DIRS)

.PHONY: black
black: ## Black formatter
	@echo -e "\033[92m➜ $@ \033[0m"
	@black $(PYTHON_FMT_DIRS)

.PHONY: black-lint
black-lint: ## Lint with Black
	@echo -e "\033[92m➜ $@ \033[0m"
	@black --check $(PYTHON_FMT_DIRS)

.PHONY: fmt
fmt: black isort ## Formatting using black  and isort (in that order)

.PHONY: fmt-lint
fmt-lint: black-lint isort-lint ## Lint with formatters
