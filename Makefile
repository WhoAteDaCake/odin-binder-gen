.PHONY: check
check:
	odin-nightly check ./dist/output.odin

.PHONY: init
init:
	git clone git@github.com:Platin21/odin-clang.git

.PHONY: build
build:
	odin-nightly build \
		main.odin \
		-out:dist/main \
		-extra-linker-flags:-lclang \
		-debug

.PHONY: run
run: build
	./dist/main

.PHONY: deps
deps:
	clib install clibs/buffer
	clib install flag

.PHONY: build-deps
build-deps:
	cd deps/buffer && \
		gcc -shared -I. -o buffer.so -fPIC buffer.c