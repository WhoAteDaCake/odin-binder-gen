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

print_func_decl :: proc(s: ^State, t: ^types.Type, v: types.Func) {
    pprintf(s, "%s :: %s --- \n", name(t), func_to_s(t, v))
}

print_struct_decl :: proc(s: ^State, t: ^types.Type, meta: string, fields: []^types.Type) {
    param_l := params_to_s(fields, ",\n")
    defer delete(param_l)

    pprintf(s, "%s :: struct %s {{\n", name(t), meta)
    pprintf(s, "%s,\n", param_l)
    pprintf(s, "}}\n")
}

print_typedef_decl :: proc(s: ^State, t: ^types.Type, v: types.Typedef) {
    pprintf(s, "%s :: %s\n", name(t), type_to_s(v.base))
} 

print_enum_decl :: proc(s: ^State, t: ^types.Type, v: types.EnumDecl) {
    param_l := params_to_s(v.fields, ",\n")
    defer delete(param_l)

    pprintf(s, "%s :: enum %s {{\n", name(t), type_to_s(v.type_))
    pprintf(s, "%s,\n", param_l)
    pprintf(s, "}}\n")
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
                print_struct_decl(s, t, "", v.fields)
            case types.Typedef:
                print_typedef_decl(s, t, v)
            case types.EnumDecl:
                print_enum_decl(s, t, v)
            case types.Union:
                print_struct_decl(s, t, "#raw_union", v.fields)
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

