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

    if v.type_ in types.BUILT_INS {
        // fmt.println(types.BUILT_INS[v.type_])
        // return type_to_s(types.BUILT_INS[v.name])
        strings.write_string(&buffer, types.BUILT_INS[v.type_].type_)
    } else {
        if (v.ctype) {
            strings.write_string(&buffer, C_PREFIX)
        }
        strings.write_string(&buffer, v.type_)
    }
    
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

func_to_s :: proc(t: ^types.Type, v: types.Func) -> string {
    param_l := params_to_s(v.params, ", ")
    defer delete(param_l)

    ret := ""

    #partial switch r_v in v.ret.variant {
        case types.Primitive:
            if r_v.type_ != "rawptr" do ret = type_to_s(v.ret)
        case:
            ret = type_to_s(v.ret)
    }

    if len(ret) != 0 {
        ret = fmt.aprintf(" -> %s", ret)
    }
    return fmt.aprintf("proc(%s)%s", param_l, ret)
}


params_to_s :: proc(ls: []^types.Type, join_on: string) -> string {
    params := make([]string, len(ls))
    defer {
        for param in params do delete(param)
        delete(params) 
    }
    
    for param, index in ls {
        // Is this always field_decl_to_s ?
        #partial switch v in param.variant {
            case types.FieldDecl:
                params[index] = field_decl_to_s(v)
            case:
                // Unnamed
                t := types.FieldDecl{
                    fmt.aprintf("unamed%d", index),
                    param,
                }
                params[index] = field_decl_to_s(t)
                // fmt.println(param.variant)
                // fmt.println("Unexpected field")
        }
    }

    return strings.join(params, join_on)
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
        case types.Func:
            return func_to_s(t, v)
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
    // if name 
    return name
}

name :: proc {name_of_type, name_of_string}