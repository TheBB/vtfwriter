ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

.PHONY: build
build:
	echo $(ROOT_DIR)
	pdm build -d $(ROOT_DIR)/../dist/
