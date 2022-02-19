package main

import "./parser"
import "./layout"
import "./printer"

main :: proc () {
    entries := parser.parse()
    defer delete(entries)
    state := layout.resolve(entries)
    printer.run(state)
}

