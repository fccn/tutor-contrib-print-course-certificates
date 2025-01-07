
.DEFAULT_GOAL := help
.PHONY: docs

PACKAGE=tutorprint_course_certificates
PROJECT=tutor_contrib_print_course_certificates

SRC_DIRS = ./tutorprint_course_certificates
BLACK_OPTS = --exclude templates ${SRC_DIRS}
UPGRADE=CUSTOM_COMPILE_COMMAND='make upgrade' pip-compile --upgrade

###### Development

COMMON_CONSTRAINTS_TXT=requirements/common_constraints.txt
.PHONY: $(COMMON_CONSTRAINTS_TXT)
$(COMMON_CONSTRAINTS_TXT):
	wget -O "$(@)" https://raw.githubusercontent.com/edx/edx-lint/master/edx_lint/files/common_constraints.txt || touch "$(@)"

upgrade: export CUSTOM_COMPILE_COMMAND=make upgrade
upgrade: $(COMMON_CONSTRAINTS_TXT)
	## update the requirements/*.txt files with the latest packages satisfying requirements/*.in
	pip install -qr requirements/pip-tools.txt
	$(UPGRADE) --allow-unsafe --rebuild -o requirements/pip.txt requirements/pip.in
	$(UPGRADE) -o requirements/pip-tools.txt requirements/pip-tools.in
	pip install -qr requirements/pip.txt
	pip install -r requirements/pip-tools.txt
	$(UPGRADE) -o requirements/base.txt requirements/base.in
	$(UPGRADE) -o requirements/dev.txt requirements/dev.in

dev-requirements: ## Install packages from developer requirement files
	pip uninstall --yes $(PROJECT)
	pip install -e .[dev]
.PHONY: dev-requirements

requirements: ## Install package
	pip uninstall --yes $(PROJECT)
	pip install -e .
.PHONY: requirements

build-pythonpackage: ## Build Python packages ready to upload to pypi
	python setup.py sdist bdist_wheel
.PHONY: build-pythonpackage

# Warning: These checks are not necessarily run on every PR.
test: test-types test-format  ## Run all tests.
.PHONY: test

test-format: ## Run code formatting tests
	black --check --diff $(BLACK_OPTS)
.PHONY: test-format

test-types: ## Run type checks.
	mypy --exclude=templates --ignore-missing-imports --implicit-reexport --strict ${SRC_DIRS}
.PHONY: test-types

format: ## Format code automatically
	black $(BLACK_OPTS)
.PHONY: format

###### Deployment

release: test release-unsafe ## Create a release tag and push it to origin
.PHONY: release

release-unsafe:
	$(MAKE) release-tag release-push TAG=v$(shell make version)
.PHONY: release-unsafe

release-tag:
	@echo "=== Creating tag $(TAG)"
	git tag -d $(TAG) || true
	git tag $(TAG)
.PHONY: release-tag

release-push:
	@echo "=== Pushing tag $(TAG) to origin"
	git push origin
	git push origin :$(TAG) || true
	git push origin $(TAG)
.PHONY: release-push

###### Additional commands

version: ## Print the current tutor version
	@python -c 'import io, os; about = {}; exec(io.open(os.path.join("$(PACKAGE)", "__about__.py"), "rt", encoding="utf-8").read(), about); print(about["__version__"])'
.PHONY: version

ESCAPE = 
help: ## Print this help
	@grep -E '^([a-zA-Z_-]+:.*?## .*|######* .+)$$' Makefile \
		| sed 's/######* \(.*\)/@               $(ESCAPE)[1;31m\1$(ESCAPE)[0m/g' | tr '@' '\n' \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[33m%-30s\033[0m %s\n", $$1, $$2}'
