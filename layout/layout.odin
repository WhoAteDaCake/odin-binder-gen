package layout

import "../types"

State :: struct {
    defs: [dynamic]^types.Type,
    fns: [dynamic]^types.Type,
}

resolve :: proc(entries: [dynamic]^types.Type) -> State {
    state := State{make([dynamic]^types.Type), make([dynamic]^types.Type)}

    for entry in entries {
        append(&state.fns, entry)
    }

    return state
}