SHELL ?= /bin/bash

dkr_build: ## Build all images of the CDN
	@ docker build -t cdn_npm_caddy .
	@ docker build -q --target cdn_npm_builder -t cdn_npm_caddy:builder .
	@ docker build -q --target cdn_npm_caddy -t cdn_npm_caddy:caddy .

dkr_rebuild: ## Rebuild all images of the CDN
	@ docker build --pull -t cdn_npm_caddy .
	@ docker build -q --target cdn_npm_builder -t cdn_npm_caddy:builder .
	@ docker build -q --target cdn_npm_caddy -t cdn_npm_caddy:caddy .

dkr_run: dkr_build ## Run the full-built CDN Caddy server (without browse)  on http://127.0.0.1:7080
	@ docker run -it --rm \
			-p 7080:80 -p 7043:443 -p 7019:2019 \
			$$(docker build -q .)

dkr_cdn_vol: ## Build all images of the CDN
	@ docker build --target cdn_npm_caddy -t cdn_npm_caddy:caddy .
	@ docker build --target cdn_npm_builder -t cdn_npm_caddy:builder .

dkr_cdn: dkr_cdn_vol ## Run a locally-mounted "cdn-npm/" with browsable CDN Caddy server on http://127.0.0.1:7080
	@ docker run --rm -it \
		-e CDN_FILE_SERVER_CFG=browse \
		-p 7080:80 -p 7043:443 -p 7019:2019 \
		-v $$(pwd)/cdn-npm:/srv \
		$$(docker build -q --target cdn_npm_caddy .)

dkr_cdn_update: dkr_cdn_vol ## update the local CDN from cdn-deps.txt
	@ docker run --rm -it \
		-v $$(pwd)/cdn-npm:/srv \
		$$(docker build -q --target cdn_npm_builder .)

.ONESHELL: dkr_run dkr_build dkr_rebuild

.PHONY: help 

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


.DEFAULT_GOAL := help

