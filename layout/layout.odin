package layout

import "../types"
import "../state"

import "core:fmt"
import "core:strings"

State :: state.LayoutState

handle_struct :: proc(s: ^State, t: ^types.Type, fields: []^types.Type) {
    if len(t.name) == 0 {
        t.name = fmt.aprintf("_anon_%d", s.id)
        s.id += 1
    }
    append(&s.defs, t)
    for field in fields {
        handle(s, field)
    }
}

handle_typedef :: proc(s: ^State, t: ^types.Type, v: types.Typedef) {
    if strings.contains(v.name, "struct ") {
        name, was_allocation := strings.remove(v.name, "struct ", 1)
        // if was_allocation {
        //     delete(v.name)
        // }
        t.variant = types.Typedef{name, v.base}
    }
    // fmt.println(v.base)
    append(&s.defs, t)
}

handle_enum :: proc(s: ^State, t: ^types.Type, v: types.EnumDecl) {
    if len(t.name) == 0 {
        t.name = fmt.aprintf("_anon_%d", s.id)
        s.id += 1
    }
    append(&s.defs, t)
}

handle :: proc(s: ^State, t: ^types.Type) {
    #partial switch v in t.variant {
        case types.Struct:
            handle_struct(s, t, v.fields)
        case types.Typedef:
            handle_typedef(s, t, v)
        case types.Func:
            append(&s.fns, t)
        case types.EnumDecl:
            handle_enum(s, t, v)
        case types.Union:
            handle_struct(s, t, v.fields)
    }
    // fmt.println(t)
}

type_of_variant :: proc(id: u32, name: string, v: types.TypeVariant) -> ^types.Type {
    t := new(types.Type)
    t.name = ""
    t.id  = id
    t.variant = v
    return t
}

add_builtins :: proc(s: ^State) {
    for k, v in types.BUILT_INS {
        s.builtins[k] = type_of_variant(0, k, v)
    }
}

resolve :: proc(ps: ^state.ParserState) -> ^State {
    s := state.layout()

    add_builtins(s)

    for _, t in ps.registered {
        #partial switch v in t.variant {
            case types.Node_Ref:
                if v.base == nil {
                    found := ps.cached[v.hash]
                    if found == nil {
                        if v.name in s.builtins {
                            found = s.builtins[v.name]
                        }
                        if found == nil {
                           fmt.println(v.name) 
                        }
                        // s.builtin[k]
                        // fmt.println(v.name)
                    }
                    t.variant = types.Node_Ref{found, v.hash, v.name}
                }
        } 
    } 

    for entry in ps.declared do handle(s, entry)

    // fmt.println("----------")
    return s
}