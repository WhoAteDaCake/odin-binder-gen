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

pprint :: proc(using s: ^State, value: string,)
{
    strings.write_string(buffer, value);
}


print_func_decl :: proc(s: ^State, t: ^types.Type, v: types.Func) {
    pprintf(s, "%s :: %s --- \n", name(t), func_to_s(t, v))
}

print_struct_decl :: proc(s: ^State, t: ^types.Type, meta: string, fields: []^types.Type) {
    if len(fields) == 0 {
        return
    }

    param_l := params_to_s(fields, ",\n", true)
    defer delete(param_l)

    pprintf(s, "%s :: struct %s {{\n", name(t), meta)
    pprintf(s, "%s,\n", param_l)
    pprintf(s, "}}\n")
}

print_typedef_decl :: proc(s: ^State, t: ^types.Type, v: types.Typedef) {
    pprintf(s, "%s :: %s\n", name(t), type_to_s(v.base))
} 

print_enum_decl :: proc(s: ^State, t: ^types.Type, v: types.EnumDecl) {
    param_l := params_to_s(v.fields, ",\n", false)
    defer delete(param_l)

    pprintf(s, "%s :: enum %s {{\n", name(t), type_to_s(v.type_))
    pprintf(s, "%s,\n", param_l)
    pprintf(s, "}}\n")
} 

print_setup :: proc(c: ^config.Config, s: ^State) {
    pprintf(s, "package %s\n\n", c.library)
    pprintf(s, "import _c \"core:c\"\n\n")
    pprintf(s, "import _os \"core:os\"\n\n")
    pprintf(s, "import _libc \"core:c/libc\"\n\n")
    pprintf(s, "foreign import %s \"%s\"\n\n", c.library, c.library_path)
}

print_builtins :: proc(s: ^State) {
    pprint(s, `
timeval :: struct {
	tv_sec: _c.long,
	tv_usec: _c.long,
}
`)
}

run :: proc (
    c: ^config.Config,
    l_state: ^state.LayoutState,
    s: ^State,
) {
    print_setup(c, s)
    print_builtins(s)

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

