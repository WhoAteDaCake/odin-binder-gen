package printer

import "core:fmt"
import "core:os"
import "core:c"
import "core:slice"
import "core:strings"

import "../layout"
import "../types"
import "../config"

State :: struct {
    buffer: ^strings.Builder,
}

pprintf :: proc(using s: ^State, fmt_str: string, args: ..any)
{
    strings.write_string(buffer, fmt.tprintf(fmt_str, ..args));
}


print_func_decl :: proc(s: ^State, t: ^types.Type, v: types.Func) {
    params := make([]string, len(v.params))
    defer {
        for param in params do delete(param)
        delete(params) 
    }
    
    for param, index in v.params {
        params[index] = type_to_s(param)
    }

    param_l := strings.join(params, ",")
    defer delete(param_l)

    ret := type_to_s(v.ret)
    defer delete(ret)

    pprintf(s, "%s :: proc(%s) -> %s --- \n", t.name, param_l, ret)
}

print :: proc(s: ^State, t: ^types.Type, variant: types.TypeVariant) {
    #partial switch v in variant  {
        case types.Func:
            print_func_decl(s, t, v)
        case:
            // fmt.println("Unexpected type received", v)
    }
}

print_setup :: proc(c: ^config.Config, s: ^State) {
    pprintf(s, "package %s\n\n", c.library)
    pprintf(s, "import _c \"core:c\"\n\n")
    pprintf(s, "foreign import %s \"%s\"\n\n", c.library, c.library_path)
    // pprintf(s, "import _c \"core:c\"\n\n")
}

run :: proc (c: ^config.Config, layout_state: layout.State) {
    buffer := strings.make_builder()
    defer 
    {
        os.write_entire_file("./dist/output.odin", transmute([]byte)strings.to_string(buffer));
        strings.destroy_builder(&buffer);
    }
    state := State{&buffer}
    print_setup(c, &state)
    
    pprintf(&state, "foreign %s {{\n", c.library)
    // strings.write_string(&buffer, "foreign  {\n");

    for item in layout_state.fns {
        print(&state, item, item.variant)
    }

    strings.write_string(&buffer, "}");
}

