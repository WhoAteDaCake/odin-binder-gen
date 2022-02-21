package printer

import "core:fmt"
import "core:os"
import "core:c"
import "core:slice"
import "core:strings"

import "../layout"
import "../types"
import "../config"
import "../state"

State :: state.PrinterState

pprintf :: proc(using s: ^State, fmt_str: string, args: ..any)
{
    strings.write_string(buffer, fmt.tprintf(fmt_str, ..args));
}

params_to_s :: proc(s: ^State, ls: []^types.Type, join_on: string) -> string {
    params := make([]string, len(ls))
    defer {
        for param in params do delete(param)
        delete(params) 
    }
    
    for param, index in ls {
        params[index] = type_to_s(param)
    }

    return strings.join(params, join_on)
}

print_func_decl :: proc(s: ^State, t: ^types.Type, v: types.Func) {
    param_l := params_to_s(s, v.params, ",")
    defer delete(param_l)

    ret := type_to_s(v.ret)
    defer delete(ret)

    pprintf(s, "%s :: proc(%s) -> %s --- \n", t.name, param_l, ret)
}

print_struct_decl :: proc(s: ^State, t: ^types.Type, v: types.Struct) {
    param_l := params_to_s(s, v.fields, ",\n")
    defer delete(param_l)

    pprintf(s, "%s :: {{\n", t.name)
    pprintf(s, "%s,\n", param_l)
    pprintf(s, "}}\n")
}

print_typedef_decl :: proc(s: ^State, t: ^types.Type, v: types.Typedef) {
    pprintf(s, "%s :: %s\n", t.name, type_to_s(v.base))
} 

print_setup :: proc(c: ^config.Config, s: ^State) {
    pprintf(s, "package %s\n\n", c.library)
    pprintf(s, "import _c \"core:c\"\n\n")
    pprintf(s, "foreign import %s \"%s\"\n\n", c.library, c.library_path)
    // pprintf(s, "import _c \"core:c\"\n\n")
}

run :: proc (
    c: ^config.Config,
    l_state: ^state.LayoutState,
    s: ^State,
) {
    print_setup(c, s)

    for t in l_state.defs {
        #partial switch v in t.variant  {
            case types.Struct:
                print_struct_decl(s, t, v)
            case types.Typedef:
                print_typedef_decl(s, t, v)
        }
    }

    pprintf(s, "foreign %s {{\n", c.library)
    // strings.write_string(&buffer, "foreign  {\n");

    for t in l_state.fns {
        #partial switch v in t.variant  {
            case types.Func:
                print_func_decl(s, t, v)
        }
        // print(s, item, item.variant)
    }

    strings.write_string(s.buffer, "}");
}

