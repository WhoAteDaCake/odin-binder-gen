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
    return fmt.aprintf("%s: %s", name(v.name), type_to_s(v.type_))
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

enum_to_s :: proc(t: ^types.Type, v: types.EnumValue) -> string {
    return fmt.aprintf("%s = %d", name(t), v.value)
}

array_to_s :: proc(t: ^types.Type, v: types.Array) -> string {
    return fmt.aprintf("[%d]%s", v.size, type_to_s(v.base))
}

type_to_s :: proc (t: ^types.Type) -> string {
    // fmt.println(t)
    #partial switch v in t.variant {
        case types.FieldDecl:
            return field_decl_to_s(v)
        case types.Primitive:
            return primitive_to_s(v)
        case types.Pointer:
            return pointer_to_s(v)
        case types.Node_Ref:
            return name(v.base)
        case types.EnumValue:
            return enum_to_s(t, v)
        case types.Array:
            return array_to_s(t, v)
        case:
            return name(t)
    }
    return ""
}

name_of_type :: proc (t: ^types.Type) -> string {
    return name_of_string(t.name)
}

name_of_string :: proc (name: string) -> string {
    return name
}

name :: proc {name_of_type, name_of_string}