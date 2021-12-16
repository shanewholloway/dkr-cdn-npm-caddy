SHELL ?= /bin/bash

dkr_build: ## Build the Image
	@ docker build .

dkr_rebuild: ## Rebuild the Image
	@ docker build --pull .

dkr_run: dkr_build ## Run the Container
	@ docker run -it --rm -p 7080:80 -p 7043:443 -p 7019:2019 $$(docker build -q .)

.ONESHELL: dkr_run dkr_build dkr_rebuild

.PHONY: help 

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


.DEFAULT_GOAL := help

