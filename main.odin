package main

import "./parser"
// import "./layout"

main :: proc () {
    entries := parser.parse()
    // layout.resolve(entries) 
}

