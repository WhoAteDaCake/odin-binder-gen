# !/usr/bin/env bash

odin-nightly build \
    main.odin \
    -out:dist/main \
    -extra-linker-flags:-lclang \
    -debug \
    || { echo 'my_command failed' ; exit 1; }

./dist/main