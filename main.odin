package main

import "./parser"
import "./layout"

main :: proc () {
    entries := parser.parse()
    defer delete(entries)
    layout.resolve(entries) 
}

