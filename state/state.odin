package state

import "core:runtime"
import "core:strings"
import "../types"
import "../config"

ParserState :: struct {
    declared: [dynamic]^types.Type,
    cached: map[u32]^types.Type,
    registered: map[u32]^types.Type,
    builtins: map[string]^types.Type,
    // Used when parsing subfields of functions or structs 
    pending: [dynamic]^types.Type,
    config: ^config.Config,
    id: u32,
    allocator: ^runtime.Allocator,
}

parser :: proc(c: ^config.Config, allocator: ^runtime.Allocator) -> ^ParserState {
    s := new(ParserState)
    s.allocator = allocator
    s.declared = make([dynamic]^types.Type)
    s.pending = make([dynamic]^types.Type)
    s.cached = make(map[u32]^types.Type)
    s.registered = make(map[u32]^types.Type)
    s.builtins = make(map[string]^types.Type)
    s.config = c
    s.id = 0
    return s
}

LayoutState :: struct {
    defs: [dynamic]^types.Type,
    fns: [dynamic]^types.Type,
    id: uint,
}

layout :: proc() -> ^LayoutState {
    s := new(LayoutState)
    s.defs = make([dynamic]^types.Type)
    s.fns = make([dynamic]^types.Type)
    // Builtins are id 0
    s.id = 1
    return s
}

PrinterState :: struct {
    buffer: ^strings.Builder,
    id: uint,
}

printer :: proc(buffer: ^strings.Builder) -> ^PrinterState {
    s := new(PrinterState)
    s.buffer = buffer
    s.id = 0
    return s
}