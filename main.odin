package main

import "core:strings"
import "core:os"

import "./parser"
import "./layout"
import "./printer"
import "./config"
import "./state"

main :: proc () {
    cfg := config.Config{
        []string{"deps/flag", "test/headers"},
        "deps/flag/flag.so",
        "flag",
    }

    p_state := parser.parse(&cfg)
    // defer delete(entries)
    l_state := layout.resolve(p_state)

    buffer := strings.make_builder()
    defer 
    {
        os.write_entire_file("./dist/output.odin", transmute([]byte)strings.to_string(buffer));
        strings.destroy_builder(&buffer);
    }

    pr_state := state.printer(&buffer)
    printer.run(&cfg, l_state, pr_state)
}

