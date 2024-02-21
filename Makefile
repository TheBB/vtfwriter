.PHONY: build
build:
	pdm build

.PHONY: build-stubs
build-stubs:
	make -C vtfwriter-stubs build
