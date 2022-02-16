package parser

import "core:runtime"
import "../types"

State :: struct {
    declared: [dynamic]^types.Type,
    cached: map[u32]^types.Type,
    allocator: ^runtime.Allocator,
}

make_state :: proc(allocator: ^runtime.Allocator) -> ^State {
    value := new(State)
    value.allocator = allocator
    value.declared = make([dynamic]^types.Type)
    value.cached = make(map[u32]^types.Type)
    return value
}
