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
}

make_state :: proc(c: ^config.Config, allocator: ^runtime.Allocator) -> ^State {
    value := new(State)
    value.allocator = allocator
    value.declared = make([dynamic]^types.Type)
    value.pending = make([dynamic]^types.Type)
    value.cached = make(map[u32]^types.Type)
    value.config = c
    return value
}
