package main

import "./parser"
import "./layout"
import "./printer"

main :: proc () {
    config := parser.Config{[]string{"deps/buffer"}}

    entries := parser.parse(&config)
    defer delete(entries)
    state := layout.resolve(entries)
    printer.run(state)
}

