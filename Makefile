.DEFAULT_GOAL := all

SHELL := /bin/bash

makefile := $(abspath $(lastword $(MAKEFILE_LIST)))
makefile_dir := $(dir $(makefile))

slug := sasaplus1/environment

.PHONY: all
all: ## output targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(makefile) | awk 'BEGIN { FS = ":.*?## " }; { printf "\033[36m%-30s\033[0m %s\n", $$1, $$2 }'

.PHONY: build
build: ## build user-data.img
	DOCKER_BUILTKIT=1 docker build -t $(slug) .
	docker run --rm -v "$$PWD:/mnt" $(slug) user-data.img user-data

.PHONY: download-image
download-image: image := https://cloud-images.ubuntu.com/releases/focal/release-20200916/ubuntu-20.04-server-cloudimg-amd64.img
download-image: ## download Ubuntu image
	curl -C - -fsLSOC '$(image)'

.PHONY: run
run: options := -net nic -net user,hostfwd=tcp::2222-:22
run: options += -drive file=ubuntu-20.04-server-cloudimg-amd64.img,format=qcow2
run: options += -drive file=user-data.img,format=raw
run: options += -snapshot -k ja -m 2G
#run: options += -M accel=hvf --cpu host
#run: options += -enable-kvm -nographic
#run: options += -drive if=pflash,format=raw,readonly,file=/usr/share/OVMF/OVMF_CODE.fd
#run: options += -drive if=pflash,format=raw,file=OVMF_VARS.fd
run: ## run my environment
	qemu-system-x86_64 $(options)
