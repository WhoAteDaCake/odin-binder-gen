package printer

import "../layout"
import "../types"

import "core:fmt"
import "core:os"
import "core:c"
import "core:slice"
import "core:strings"

C_PREFIX :: string("_c.")

field_decl_to_s :: proc(v: types.FieldDecl) -> string {
    return fmt.aprintf("%s: %s", v.name, type_to_s(v.type_))
}

primitive_to_s :: proc(v: types.Primitive) -> string {
    buffer := strings.make_builder()

    if (v.ctype) {
        strings.write_string(&buffer, C_PREFIX)
    }
    strings.write_string(&buffer, v.type_)
    
    return strings.to_string(buffer)
}

pointer_to_s :: proc(v: types.Pointer) -> string {
    // Could these be done within layout module?
    t := type_to_s(v.base)
    if t == "rawptr" {
        return t
    }
    if t == "_c.char" && v.is_const {
        return "cstring"
    }
    return fmt.aprintf("^%s", type_to_s(v.base))  
}

type_to_s :: proc (t: ^types.Type) -> string {
    #partial switch v in t.variant {
        case types.FieldDecl:
            return field_decl_to_s(v)
        case types.Primitive:
            return primitive_to_s(v)
        case types.Pointer:
            return pointer_to_s(v)
    }
    return ""
}