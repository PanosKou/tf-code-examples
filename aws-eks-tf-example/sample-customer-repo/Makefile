# Default settings
SHELL := /bin/bash
$(VERBOSE).SILENT:
.DEFAULT_GOAL := help

# Behave variables
BEHAVE_FEATURE_DIR := tests/behave/features
BEHAVE_TAGS := $(shell cat $(ACCOUNT_PATH)/behave_tags 2>/dev/null || echo unknown)

# More variables - don't remove unless your sure it's not being used
REGION := "eu-west-2"
AWS_DEFAULT_REGION := eu-west-2
ACCOUNT_PATH ?= not_set
KUBE_COMMAND ?= not_set
CURRENT_UID := $(shell id -u)
CURRENT_GID := $(shell id -g)
DOCKER_COMPOSE_PULL := $(shell docker-compose pull || true)
TF_ARTIFACT := /opt/app/$(ACCOUNT_PATH)/terraform.plan
ACCOUNT_ID := "$(shell cat $(ACCOUNT_PATH)/_account_id 2>/dev/null || echo unknown)"
ACCOUNT_NAME := "$(shell cat $(ACCOUNT_PATH)/_account_name 2>/dev/null || echo unknown)"
CLUSTER_NAME := $(shell echo $(ACCOUNT_PATH) | awk -F'/' '{print $$NF}')
TF_PATH := $(ACCOUNT_PATH)
APISERVER := "" # Kube API address, we get it from terraform output
DOCKER_COMPOSE := docker-compose run -u "$(shell id -u)"
GENERATE_PASSWD_RESULT:=$(shell $(DOCKER_COMPOSE) -e USER_ID=$(CURRENT_UID) -e GROUP_ID=$(CURRENT_GID)  passwd-gen > passwd)
# BDD terraform compliance tests per account spoke
BDD_TFCOMPLIANCE_DIR := /opt/app/$(ACCOUNT_PATH)/tests/compliance-tests/
TESTS_REPO := "git@github.com:example-test-repo/aws-eks-tf-modules-tests.git"

# Export values required to be passed to docker env in make entries
export TF_PATH
export AWS_DEFAULT_REGION
export CLUSTER_NAME

# Docker compose calls
AWS := $(DOCKER_COMPOSE) aws
AWS_BASH := $(DOCKER_COMPOSE) --entrypoint="/bin/bash" aws
TF := $(DOCKER_COMPOSE) terraform
PYTHON := $(DOCKER_COMPOSE) python
PYTHON_BASH := $(DOCKER_COMPOSE) --entrypoint="/bin/bash" python
BEHAVE := $(DOCKER_COMPOSE) --entrypoint="behave" python
KUBECTL_BASH := $(DOCKER_COMPOSE) --entrypoint="/bin/bash" terraform
KUBE := $(DOCKER_COMPOSE) --entrypoint="kubectl" kube --kubeconfig /opt/app/kube_config.yaml
KUBEBENCH := $(DOCKER_COMPOSE) --entrypoint="/bin/bash" terraform ../../kubebench/kube-bench.sh
KUBE_SHELL := $(DOCKER_COMPOSE) kube
KUBE_BASH := $(DOCKER_COMPOSE) --entrypoint="/bin/bash -c" kube
TERRAFORM_COMPLIANCE := $(DOCKER_COMPOSE) terraform-compliance
CHECKOV := $(DOCKER_COMPOSE) checkov
GIT := $(DOCKER_COMPOSE) --entrypoint="/usr/bin/git" python 


## Entry Points - Terraform steps mostly

tf_lint: tf_fmt tf_validate

tf_init: assume_role
	echo "Terraform Init"
	AWS_SHARED_CREDENTIALS_FILE="/opt/app/$(TF_PATH)/.credentials.aws" \
	$(TF) init -upgrade

tf_fmt:
	echo "Terraform Fmt Check"
	$(TF) fmt -check -recursive "/opt/app/$(ACCOUNT_PATH)"

tf_validate: tf_init
	echo "Terraform Validate"
	$(TF) validate

clean:
	echo "Clean - Removing .terraform directory and purging orphaned docker networks"
	$(DOCKER_COMPOSE) --entrypoint="rm -rf .terraform/modules" terraform
	docker-compose down --remove-orphans 2>/dev/null

tf_plan_as_json: tf_plan
	echo "Pipe plan into json file"
	$(TF) show -json $(TF_ARTIFACT) > tfplan.json

checkov: tf_plan_as_json
	echo "Checkov on Plan"
	$(CHECKOV) -f /opt/app/tfplan.json

behave: assume_role k8s_config git_clone_bdd
	echo "Behave testing"
	export ACCOUNT_NAME=$(ACCOUNT_NAME); \
	AWS_SHARED_CREDENTIALS_FILE="/opt/app/$(TF_PATH)/.credentials.aws" \
	$(BEHAVE) $(BEHAVE_FEATURE_DIR) --tags=$(BEHAVE_TAGS)

kubebench: assume_role k8s_config
	echo "CIS kube bench"
	echo "Working with [$(ACCOUNT_PATH)]"
	AWS_SHARED_CREDENTIALS_FILE="/opt/app/$(TF_PATH)/.credentials.aws" \
	$(KUBEBENCH)

tf_plan: tf_init
	echo "Terraform Plan"
	# tf plan - return code 2 means changes are waiting to be applied
	# touches a file tf_plan_changes if there are changes to be made
	# exits with an error if return code was anything other than 2
	$(TF) plan -lock-timeout=60m -detailed-exitcode -out $(TF_ARTIFACT) \
	|| ( (($$? == 2)) && $(TF) show $(TF_ARTIFACT) > $(ACCOUNT_PATH)/tf_plan_changes || exit 1 )

tf_apply: tf_init
	AWS_SHARED_CREDENTIALS_FILE="/opt/app/$(TF_PATH)/.credentials.aws" \
	$(TF) apply -lock-timeout=60m -auto-approve


tf_destroy: clean tf_init
	AWS_SHARED_CREDENTIALS_FILE="/opt/app/$(TF_PATH)/.credentials.aws" \
	$(TF) destroy -auto-approve


tf_output: tf_init
	${TF} output


## Shell into containers

# AWS Shell
aws_bash: assume_role
	echo "Working with [$(ACCOUNT_PATH)]"
	AWS_SHARED_CREDENTIALS_FILE="/opt/app/${ACCOUNT_PATH}/.credentials.aws" \
	AWS_DEFAULT_REGION="eu-west-2" \
	$(AWS_BASH)

# TF Shell
terraform_bash: assume_role
	export ACCOUNT_ID="$(ACCOUNT_ID)" && \
	AWS_SHARED_CREDENTIALS_FILE="/opt/app/$(TF_PATH)/.credentials.aws" \
	$(DOCKER_COMPOSE) --entrypoint=bash terraform

# Run terraform-compliance container
compliance_bash: tf_plan_as_json
	$(DOCKER_COMPOSE) --entrypoint=bash terraform-compliance

# Python Shell
python_bash:
	$(PYTHON_BASH)


## Helpers / Misc / Other / Testing

# Assume role into the specific account in ACCOUNT_PATH
assume_role:
	echo "Authing to specific account $(ACCOUNT_NAME)" >&2
	CREDENTIALS_PATH="/opt/app/${ACCOUNT_PATH}" \
	TF_PATH=$(TF_PATH) \
	ACCOUNT_ID=$(ACCOUNT_ID) \
	ACCOUNT_NAME=$(ACCOUNT_NAME) \
	$(AWS_BASH) scripts/assume-role.sh >&2

k8s_config:
	echo "Setting kube config to be correct cluster"
	AWS_SHARED_CREDENTIALS_FILE="/opt/app/$(TF_PATH)/.credentials.aws" \
	AWS_DEFAULT_REGION="eu-west-2" \
	$(DOCKER_COMPOSE) --entrypoint="aws" python eks --region ${AWS_DEFAULT_REGION} update-kubeconfig --kubeconfig /opt/app/config --name $(CLUSTER_NAME)

# Removes state file lock for those troublesome crashed. Usage; make force-unlock LOCK_ID=[lockId]
unlock: tf_init
	${TF} force-unlock -force ${LOCK_ID}

git_clone_bdd:
	echo "Clone Compliance BDD tests"
	$(GIT) clone $(TESTS_REPO) tests &> /dev/null || git -C tests pull
