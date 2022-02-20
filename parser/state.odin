package parser

import "core:runtime"
import "../types"
import "../config"


State :: struct {
    declared: [dynamic]^types.Type,
    cached: map[u32]^types.Type,
    allocator: ^runtime.Allocator,
    // Used when parsing subfields of functions or structs 
    pending: [dynamic]^types.Type,
    config: ^config.Config,
    id: int,
}

make_state :: proc(c: ^config.Config, allocator: ^runtime.Allocator) -> ^State {
    s := new(State)
    s.allocator = allocator
    s.declared = make([dynamic]^types.Type)
    s.pending = make([dynamic]^types.Type)
    s.cached = make(map[u32]^types.Type)
    s.config = c
    s.id = 0
    return s
}
