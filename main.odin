package main

import "./parser"
import "./layout"
import "./printer"
import "./config"

main :: proc () {
    cfg := config.Config{
        []string{"deps/buffer"},
        "deps/buffer/buffer.so",
        "buffer",
    }

    entries := parser.parse(&cfg)
    defer delete(entries)
    state := layout.resolve(entries)
    printer.run(&cfg, state)
}

