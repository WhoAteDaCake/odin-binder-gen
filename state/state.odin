package state

import "core:runtime"
import "../types"
import "../config"

ParserState :: struct {
    declared: [dynamic]^types.Type,
    cached: map[u32]^types.Type,
    registered: map[u32]^types.Type,
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
    s.config = c
    s.id = 0
    return s
}
