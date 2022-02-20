package layout

import "../types"
import "../state"

import "core:fmt"
import "core:strings"

State :: state.LayoutState

handle_struct :: proc(s: ^State, t: ^types.Type, v: types.Struct) {
    if len(t.name) == 0 {
        t.name = fmt.aprintf("_anon_%d", s.id)
        s.id += 1
    }
    append(&s.defs, t)
    for field in v.fields {
        handle(s, field)
    }
}

handle_typedef :: proc(s: ^State, t: ^types.Type, v: types.Typedef) {
    if strings.contains(t.name, "struct ") {
        name, was_allocation := strings.remove(t.name, "struct ", 1)
        if was_allocation {
            delete(t.name)
        }
        t.name = name
    }
    append(&s.defs, t)
}

handle_func :: proc(s: ^State, t: ^types.Type, v: types.Func) {
    append(&s.fns, t)
}

handle :: proc(s: ^State, t: ^types.Type) {
    #partial switch v in t.variant {
        case types.Struct:
            handle_struct(s, t, v)
        case types.Typedef:
            handle_typedef(s, t, v)
        case types.Func:
            handle_func(s, t, v)
    }   
}

resolve :: proc(ps: ^state.ParserState) -> ^State {
    s := state.layout()

    for entry in ps.declared do handle(s, entry)

    return s
}