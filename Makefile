SHELL ?= /bin/bash

dkr_build: ## Build the Image
	@ docker build .

dkr_tag: dkr_build ## Build the Image
	@ docker build -q --target cdn_npm_builder -t cdn_npm_builder .
	@ docker build -q --target cdn_npm_caddy -t cdn_npm_caddy .

dkr_rebuild: ## Rebuild the Image
	@ docker build --pull .

dkr_run: dkr_build ## Run the Container
	@ docker run -it --rm \
			-p 7080:80 -p 7043:443 -p 7019:2019 \
			$$(docker build -q --target cdn_npm_caddy .)

dkr_cdn_build: dkr_tag
	@ docker run --rm -it \
		-v $$(pwd)/cdn-npm:/srv cdn_npm_builder

dkr_cdn_browse: dkr_tag
	@ docker run --rm -it \
		-e CDN_FILE_SERVER_CFG=browse \
		-p 7080:80 -p 7043:443 -p 7019:2019 \
		-v $$(pwd)/cdn-npm:/srv cdn_npm_caddy

dkr_cdn: dkr_tag
	@ docker run --rm -it \
		-p 7080:80 -p 7043:443 -p 7019:2019 \
		-v $$(pwd)/cdn-npm:/srv cdn_npm_caddy

.ONESHELL: dkr_run dkr_build dkr_rebuild

.PHONY: help 

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


.DEFAULT_GOAL := help

