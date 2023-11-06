# use some sensible default shell settings
SHELL := /bin/bash
$(VERBOSE).SILENT:
.DEFAULT_GOAL := help

CURRENT_UID := $(shell id -u)
CURRENT_GID := $(shell id -g)

ARTIFACTORY_CREDENTIALS=ARTIFACTORY_USERNAME=anonymous ARTIFACTORY_PASSWORD=''

# reusable docker-compose command
$(info Looking up docker image tags. This may take a moment...)
DOCKER_COMPOSE_ENV_VARS := $(shell ${ARTIFACTORY_CREDENTIALS} \
  docker-compose -f docker-compose-tags.yml run semver-get-tags \
  -d /opt/build/docker-compose.yml -q | tail -n1)
$(info Using docker compose env vars: $(DOCKER_COMPOSE_ENV_VARS))

# some default variable setting
MODULE ?= not_set
RE_MODULES := ^(modules/.*)$$
TF_PATH=modules/$(MODULE)
export AWS_DEFAULT_REGION="eu-west-2"
export TF_PATH

# reusable docker-compose command
DOCKER_COMPOSE := $(DOCKER_COMPOSE_ENV_VARS) docker-compose
DOCKER_COMPOSE_RUN := ${DOCKER_COMPOSE} run -u "$(CURRENT_UID)"
DOCKER_COMPOSE_PULL := $(shell $(DOCKER_COMPOSE) pull || true)
GENERATE_PASSWD_RESULT:=$(shell $(DOCKER_COMPOSE_RUN) -e USER_ID=$(CURRENT_UID) -e GROUP_ID=$(CURRENT_GID) passwd-gen > passwd)

# docker-compose calls
AWS := $(DOCKER_COMPOSE_RUN) aws
TF := $(DOCKER_COMPOSE_RUN) terraform
TF_LINT := $(DOCKER_COMPOSE_RUN) tflint --loglevel=info
TF_SEC := $(DOCKER_COMPOSE_RUN) tfsec -e AWS009
CHECKOV := $(DOCKER_COMPOSE_RUN) checkov

##@ Entry Points
all: test

tf_init: _validate
	echo "################################################################################"
	echo "                   tf_init on module $(MODULE)                                   "
	echo "################################################################################"
	$(TF) init -input=false -backend=false -lock=false -upgrade

tflint: _validate
	echo "################################################################################"
	echo "                   tflint on module $(MODULE)                                   "
	echo "################################################################################"
	$(TF_LINT)

tf_fmt_check_only: _validate
	echo "################################################################################"
	echo "                   terraform fmt (Check only) on module $(MODULE)                            "
	echo "################################################################################"
	$(TF) fmt -check

tf_fmt: _validate
	echo "################################################################################"
	echo "                   terraform fmt on module $(MODULE)                            "
	echo "################################################################################"
	$(TF) fmt

tf_validate: _validate tf_init
	echo "################################################################################"
	echo "                    terraform validate on module $(MODULE)                      "
	echo "################################################################################"
	$(TF) validate

tf_sec: _validate tf_init
	echo "################################################################################"
	echo "                     tfsec on module $(MODULE)                                  "
	echo "################################################################################"
	$(TF_SEC) .

checkov: _validate
	echo "################################################################################"
	echo "                   checkov on module $(MODULE)                                   "
	echo "################################################################################"
	$(CHECKOV) -d . --external-checks-dir=/opt/app/tests/checkov

# Runs targets and expects to hit errors. Tests the make targets are working and detecting known errors!
makefiletests: export MODULE = test-module
makefiletests:
	echo "################################################################################"
	echo "                Running makefile tests with $(MODULE)                           "
	echo "################################################################################"
	${MAKE} tflint; if [ "$$?" != "2" ]; then exit 1; fi
	${MAKE} tf_fmt; if [ "$$?" != "2" ]; then exit 1; fi
	${MAKE} tf_validate; if [ "$$?" != "2" ]; then exit 1; fi
	${MAKE} tf_sec; if [ "$$?" != "2" ]; then exit 1; fi
	${MAKE} checkov; if [ "$$?" != "2" ]; then exit 1; fi
	echo "Makefile Tests Completed! Errors can be ignored!"

lint: _validate tflint tf_fmt_check_only tf_validate

compliance: tf_sec checkov

build: _validate clean lint compliance

test: build

allmodules_test:
	for module in $$(scripts/select-modules-to-be-built.sh) ; do \
		MODULE=$$module make test; \
	done

allmodules_fmt:
	for module in $$(MODULES=all scripts/select-modules-to-be-built.sh) ; do \
		MODULE=$$module make tf_fmt; \
	done


##@ Misc
help: ## Display this help
	awk \
	  'BEGIN { \
	    FS = ":.*##"; printf "\nUsage:\n"\
			"  export MODULE=\"name of module in modules dir\"\n"\
			"  make \033[36m<target>\033[0m\n" \
	  } /^[a-zA-Z_-]+:.*?##/ { \
	    printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 \
	  } /^##@/ { \
	    printf "\n\033[1m%s\033[0m\n", substr($$0, 5) \
	  } ' $(MAKEFILE_LIST)

##@ Helpers
clean: ## Remove terraform directory and any left over docker networks
	echo "Removing .terraform directory and purging orphaned docker networks"
	$(DOCKER_COMPOSE_RUN) --entrypoint="rm -rf .terraform/modules" terraform
	$(DOCKER_COMPOSE) down --remove-orphans 2>/dev/null

_validate: ## Validate the environment variables are in the accepted list
	[[ "$(TF_PATH)" =~ $(RE_MODULES) ]] || (echo "$(MODULE) is not a valid option for MODULE var, see README" && exit 1)
	[[ -d "$(TF_PATH)" ]] || (echo "Module Path '$(TF_PATH)' for the module '$(MODULE)' DOES NOT exists, see README" && exit 1)

.PHONY: _validate clean help test build compliance lint makefiletests tf_sec tf_validate tf_fmt_check_only tflint checkov all