package main

import "./parser"
import "./layout"
import "./printer"
import "./config"
import "./state"

main :: proc () {
    cfg := config.Config{
        []string{"deps/buffer", "test/headers"},
        "deps/buffer/buffer.so",
        "buffer",
    }

    p_state := parser.parse(&cfg)
    // defer delete(entries)
    // state := layout.resolve(entries)
    // printer.run(&cfg, state)
}

