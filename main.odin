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
    l_state := layout.resolve(p_state)
    // printer.run(&cfg, state)
}

