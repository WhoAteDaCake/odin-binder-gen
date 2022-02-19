package layout

import "../types"

State :: struct {
    defs: [dynamic]^types.Type,
    fns: [dynamic]^types.Type,
}

resolve :: proc(entries: [dynamic]^types.Type) -> state {
    state := State{}

    return state
}