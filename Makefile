SHELL:=bash

aws_profile=default
aws_profile_mgt_dev=dataworks-management-dev
aws_region=eu-west-2

default: help

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: bootstrap
bootstrap: ## Bootstrap local environment for first use
	make git-hooks
	make bootstrap-terraform

.PHONY: bootstrap-terraform
bootstrap-terraform: ## Bootstrap local environment for first use
	@{ \
		export AWS_PROFILE=$(aws_profile); \
		export AWS_PROFILE_MGT_DEV=$(aws_profile_mgt_dev); \
		export AWS_REGION=$(aws_region); \
		python3 bootstrap_terraform.py; \
	}

.PHONY: git-hooks
git-hooks: ## Set up hooks in .githooks
	@git submodule update --init .githooks ; \
	git config core.hooksPath .githooks \

.PHONY: pipeline
pipeline: ## Generate and apply Concourse pipeline
	python3 generate_pipeline_code.py && aviator
