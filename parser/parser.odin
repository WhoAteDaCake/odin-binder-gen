package parser
import clang "../odin-clang"

import "core:strings"
import "core:slice"
import "core:fmt"
import "core:os"
import "core:runtime"

import "../config"
import "../types"
import "../state"

State :: state.ParserState

new_type :: proc(s: ^State) -> ^types.Type {
    t := new(types.Type)
    t.id = s.id + 1
    s.id += 1
    s.registered[t.id] = t
    return t
}

// new_type_of_variant :: proc(s: ^State, v: types.TypeVariant) -> ^types.Type {
//     t := new(types.Type)
//     t.id = s.id + 1
//     s.id += 1
//     s.registered[t.id] = t
//     t.variant = v
//     return t
// }

type_ :: proc(s: ^State, t: clang.CXType) -> ^types.Type {
    output := new_type(s)
    // fmt.println(t.kind, spelling(t))
    output.name = spelling(t)

    // if (output.name == "time_t") {
    //     fmt.println(t.kind)
    // }

    // fmt.println(t.kind)
    #partial switch t.kind {
        case .CXType_ConstantArray: {
            output.variant = types.Array{
              type_(s, clang.getArrayElementType(t)), 
              clang.getArraySize(t),
            }
        }
        case .CXType_IncompleteArray: {
            output.variant = types.Array{
              type_(s, clang.getArrayElementType(t)), 
              0,
            }
        }
        case .CXType_FunctionProto: {
            output.variant = build_function_type(s, t)
        }
        // Check if I need to handle special case for function pointers
        case .CXType_Pointer: {
            pointee := clang.getPointeeType(t)
            // fmt.println(spelling(t))
            output.variant = types.Pointer{
                type_(s, pointee),
                clang.isConstQualifiedType(pointee) == 1,
            }
        }
        case .CXType_Bool: {
            output.variant = types.primitive("bool")
        }
        case .CXType_Void: {
            output.variant = types.primitive("rawptr", false)
        }
        case .CXType_Char_S: {
            output.variant = types.primitive("char")
        }
        case .CXType_Int: {
            output.variant = types.primitive("int")
        }
        case .CXType_UInt: {
            output.variant = types.primitive("uint")
        }
        case .CXType_UShort: {
            output.variant = types.primitive("ushort")
        }
        case .CXType_Double: {
            output.variant = types.primitive("double")
        }
        case .CXType_ULong: {
            output.variant = types.primitive("ulong")
        }
        case .CXType_Long: {
            output.variant = types.primitive("long")
        }
        case .CXType_LongLong: {
            output.variant = types.primitive("longlong")
        }
        case .CXType_ULongLong: {
            output.variant = types.primitive("ulonglong")
        }
        case .CXType_UChar: {
            output.variant = types.primitive("uchar")
        }
        case .CXType_Typedef: {
            if types.is_builtin(output.name) {
                output.variant = types.primitive(output.name)
            } else if output.name in types.BUILT_INS {
                output.variant = types.BUILT_INS[output.name]
                // This will probablybe typedefs within a struct
                // fmt.println("UNEXPECTED")
            } else {
                // fmt.println(output.name)
            }
            // // fmt.println(t)
        }
        case .CXType_Elaborated: {
            cursor := clang.getTypeDeclaration(t)
            hash := clang.hashCursor(cursor)
            found := s.cached[hash]
            name := spelling(cursor)
            // TODO: redo to move builtin types here, since
            // typedef and elaborated both use it.
            if found == nil && name in types.BUILT_INS {
                found = s.builtins[name]
            } else {
                // fmt.println("missing", name)
            }
            // fmt.println(name, found)
            output.variant = types.Node_Ref{found,hash, name}
        }
        // case: fmt.println(t.kind)
    }
    // fmt.println(output)
    return output
}

build_function_type :: proc(s: ^State, t: clang.CXType) -> types.Func {
    ret := type_(s, clang.getResultType(t))
    n := cast(u32) clang.getNumArgTypes(t)
    params := make([]^types.Type, n)
    if len(params) > 0 {
        for i in 0..(n - 1) {
            at := clang.getArgType(t, i)
            // print()
            // cursor := clang.getTypeDeclaration(t)
            // fmt.println(cursor_spelling(cursor))
            params[i] = type_(s, at)
        }
    }
    return types.Func{false,ret,params}
}

visit_typedef :: proc(s: ^State, cursor: clang.CXCursor) -> types.Typedef {
    t := clang.getTypedefDeclUnderlyingType(cursor)
    base := type_(s, t)
    // fmt.println(base)
    // ^ Will this always return a NodeRef? Could be optimised 
    // Maybe is a primitive sometimes
    name := spelling(t)
    return types.Typedef{name,base}
}

visit_function_decl :: proc(s: ^State, cursor: clang.CXCursor) -> types.Func {
    ret := type_(s, clang.getCursorResultType(cursor))
    variadic := clang.Cursor_isVariadic(cursor) == 1
    
    pending := s.pending
    s.pending = make([dynamic]^types.Type)

    // if (spelling(cursor) == "_PyTime_FromTimeval") {
    //     fmt.println(spelling(cursor))
    // }

    // Parse internal arguments
    visit_children(
        s,
        cursor,
        proc(s: ^State, cursor: clang.CXCursor) -> clang.CXChildVisitResult {
            if cursor.kind == clang.CXCursorKind.CXCursor_ParmDecl {
                append(&s.pending, visit(s, cursor))
            } else {
                // append(&s.pending, visit(s, cursor))
                append(&s.declared, visit(s, cursor))
            }
            return clang.CXChildVisitResult.CXChildVisit_Continue;
        },
    )

    // Swap back to old data
    params := s.pending
    s.pending = pending

    return types.Func{variadic,ret,params[:]}
}

visit_param_decl :: proc(s: ^State, cursor: clang.CXCursor) -> types.FieldDecl {
//    fmt.println("Field: %s", spelling(cursor))
    return types.FieldDecl{
       spelling(cursor), 
       type_(s, clang.getCursorType(cursor)),
    } 
}

visit_struct_decl :: proc(s: ^State, cursor: clang.CXCursor) -> types.Struct {
    pending := s.pending
    s.pending = make([dynamic]^types.Type)
    // Parse internal arguments
    visit_children(
        s,
        cursor,
        proc(s: ^State, cursor: clang.CXCursor) -> clang.CXChildVisitResult {
            t := visit(s, cursor)
            if cursor.kind == clang.CXCursorKind.CXCursor_FieldDecl {
                append(&s.pending, t)
            } else {
                append(&s.declared, t)
            }
            return clang.CXChildVisitResult.CXChildVisit_Continue;
        },
    )
    // Swap back to old data
    ls := s.pending[:]
    s.pending = pending
    return types.Struct{ls}
}

visit_enum_decl :: proc(s: ^State, cursor: clang.CXCursor) -> types.EnumDecl {
    t := type_(s, clang.getEnumDeclIntegerType(cursor))
    pending := s.pending
    s.pending = make([dynamic]^types.Type)
    // Parse internal arguments
    visit_children(
        s,
        cursor,
        proc(s: ^State, cursor: clang.CXCursor) -> clang.CXChildVisitResult {
            if cursor.kind == clang.CXCursorKind.CXCursor_EnumConstantDecl {
                append(&s.pending, visit(s, cursor))
            }
            return clang.CXChildVisitResult.CXChildVisit_Continue;
        },
    )
    // Swap back to old data
    ls := s.pending[:]
    s.pending = pending
    return types.EnumDecl{t,ls}
} 

visit_enum_const_decl :: proc(s: ^State, cursor: clang.CXCursor) -> types.EnumValue {
    return types.EnumValue{clang.getEnumConstantDeclValue(cursor)}
}

visit_union_decl :: proc(s: ^State, cursor: clang.CXCursor) -> types.Union {
    pending := s.pending
    s.pending = make([dynamic]^types.Type)
    // Parse internal arguments
    visit_children(
        s,
        cursor,
        proc(s: ^State, cursor: clang.CXCursor) -> clang.CXChildVisitResult {
            if cursor.kind == clang.CXCursorKind.CXCursor_FieldDecl {
                append(&s.pending, visit(s, cursor))
            } else {
                // append(&s.pending, visit(s, cursor))
                append(&s.declared, visit(s, cursor))
            }
            return clang.CXChildVisitResult.CXChildVisit_Continue;
        },
    )
    // Swap back to old data
    ls := s.pending[:]
    s.pending = pending
    return types.Union{ls}
}

visit :: proc (s: ^State, cursor: clang.CXCursor) ->^types.Type {
    output := new_type(s)
    output.name = spelling(cursor)
    // fmt.println(cursor.kind)
    #partial switch cursor.kind {
        case .CXCursor_FunctionDecl: 
            output.variant = visit_function_decl(s, cursor)
        case .CXCursor_ParmDecl:
            output.variant = visit_param_decl(s, cursor)
        case .CXCursor_TypedefDecl:
            s.cached[clang.hashCursor(cursor)] = output
            output.variant = visit_typedef(s, cursor)
        case .CXCursor_StructDecl:
            s.cached[clang.hashCursor(cursor)] = output
            output.variant = visit_struct_decl(s, cursor)
        case .CXCursor_FieldDecl:
            output.variant = visit_param_decl(s, cursor)
        case .CXCursor_EnumDecl:
            s.cached[clang.hashCursor(cursor)] = output
            output.variant = visit_enum_decl(s, cursor)
        case .CXCursor_EnumConstantDecl:
            output.variant = visit_enum_const_decl(s, cursor)
        case .CXCursor_UnionDecl:
            s.cached[clang.hashCursor(cursor)] = output
            output.variant = visit_union_decl(s, cursor)
    }
    return output
}

add_builtins :: proc(s: ^State) {
    for k, v in types.BUILT_INS {
        t := new_type(s)
        t.name = k
        t.variant = v
        s.builtins[k] = t 
    }
}

parse :: proc(c: ^config.Config) -> ^State {
    idx := clang.createIndex(0, 1);
    defer clang.disposeIndex(idx)

    content: cstring = "#include \"test/headers.h\""
    file := clang.CXUnsavedFile {
        Filename = "test.c",
        Contents = content,
        Length = auto_cast len(content),
    }
    files := []clang.CXUnsavedFile{file}
    raw_flags := "-I. -I/usr/include/python3.8 -I/usr/include/python3.8  -Wno-unused-result -Wsign-compare -g -fdebug-prefix-map=/build/python3.8-4OrTnN/python3.8-3.8.10=. -specs=/usr/share/dpkg/no-pie-compile.specs -fstack-protector -Wformat -Werror=format-security  -DNDEBUG -g -fwrapv -O3 -Wall -lcrypt -lpthread -ldl  -lutil -lm -lm"

    options := clang.defaultEditingTranslationUnitOptions()

    flags := strings.split(raw_flags, " ")
    defer delete(flags)

    c_flags := make([dynamic]cstring)
    defer delete(c_flags)

    for flag in flags {
        append(&c_flags, strings.clone_to_cstring(flag))
    }

    tu := clang.CXTranslationUnit{}
    defer clang.disposeTranslationUnit(tu)

    err := clang.parseTranslationUnit2(
        idx,
        "test.c",
        raw_data(c_flags[:]),
        auto_cast len(c_flags),
        slice.first_ptr(files),
        auto_cast len(files),
        options,
        &tu,
    );

    if err != nil {
        // fmt.println(err)
    }
    if tu == nil {
        // fmt.println("Failed to configure translation unit")
        os.exit(1)
    }
    cursor := clang.getTranslationUnitCursor(tu)
    
    default_allocator: = context.allocator
    state := state.parser(c, &default_allocator)

    add_builtins(state)
    // Should be done from state package
    // defer delete(state.cached)
    // defer delete(state.pending)

    visit_children(
        state,
        cursor,
        proc(s: ^State, cursor: clang.CXCursor) -> clang.CXChildVisitResult {    
            header := cursor_header(cursor)
            // Later this should be done in layout module instead?
            matched := false
            for allowed in s.config.allowed_headers {
                if strings.contains(header, allowed) {
                    matched = true
                    break
                }
            }
            if matched {
                append(&s.declared, visit(s, cursor))
            } //else {
                // #partial switch cursor.kind {
                //     case .CXCursor_FunctionDecl:
                //         break
                //     case: 
                //         fmt.println(spelling(cursor), cursor.kind)
                // }
                // fmt.println(spelling(cursor))
            //}
            return clang.CXChildVisitResult.CXChildVisit_Continue;
        },
    )


    return state
}