SHELL:=bash

aws_profile=default

default: help

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

bootstrap: ## Bootstrap local environment for first use
	@{ \
		export AWS_PROFILE=$(aws_profile); \
		python bootstrap_terraform.py; \
	}
