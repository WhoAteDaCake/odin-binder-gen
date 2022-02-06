# !/usr/bin/env bash

odin-nightly build \
    parser \
    -out:dist/main \
    -extra-linker-flags:-lclang

./dist/main