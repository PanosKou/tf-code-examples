# Default settings
SHELL := /bin/bash
$(VERBOSE).SILENT:
.DEFAULT_GOAL := help

# More variables - don't remove unless your sure it's not being used
REGION := "eu-west-2"
AWS_DEFAULT_REGION := eu-west-2
CURRENT_UID := $(shell id -u)
CURRENT_GID := $(shell id -g)
DOCKER_COMPOSE_PULL := $(shell docker-compose pull || true)
DOCKER_COMPOSE := docker-compose run -u "$(shell id -u)"
GENERATE_PASSWD_RESULT:=$(shell $(DOCKER_COMPOSE) -e USER_ID=$(CURRENT_UID) -e GROUP_ID=$(CURRENT_GID)  passwd-gen > passwd)

# Docker compose calls
TF := $(DOCKER_COMPOSE) terraform



## Entry Points - Terraform steps mostly

epaas_eks_tf_lint: epaas_eks_tf_fmt epaas_eks_tf_validate

epaas_eks_tf_init:
	echo "Terraform Init"
	$(TF) init -backend=false

epaas_eks_tf_fmt: epaas_eks_tf_init
	echo "Terraform Fmt Check"
	$(TF) fmt -check -recursive "/opt/app/"

epaas_eks_tf_validate:
	echo "Terraform Validate"
	$(TF) validate

clean:
	echo "Clean - Removing .terraform directory and purging orphaned docker networks"
	$(DOCKER_COMPOSE) --entrypoint="rm -rf .terraform/modules" terraform
	docker-compose down --remove-orphans 2>/dev/null
