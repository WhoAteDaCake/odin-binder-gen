package parser
import clang "../odin-clang"

import "core:strings"
import "core:slice"
import "core:fmt"
import "core:os"
import "core:runtime"

import "../types"

// ParserContext :: struct {
//     allocator: ^runtime.Allocator,
//     types: [dynamic]^types.Type,
// }


// cached_cursors := make(map[u32]^types.Type);

// build_function_type :: proc(t: clang.CXType) -> types.Func {
//     output := types.Func{}
//     // fmt.println(type_spelling(t))
//     // TODO: restrict to FunctionProto, FunctionNoProto
//     output.ret = type_(clang.getResultType(t))
//     n := cast(u32) clang.getNumArgTypes(t)
//     output.params = make([]^types.Type, n)
//     for i in 0..(n - 1) {
//         at := clang.getArgType(t, i)
//         // print()
//         cursor := clang.getTypeDeclaration(t)
//         fmt.println(cursor_spelling(cursor))
//         output.params[i] = type_(at)
//     }
//     return output
// }

// build_ptr_type :: proc(t: clang.CXType) -> types.Pointer {
//     return types.Pointer{type_(clang.getPointeeType(t))}
// }

type_ :: proc(s: ^State, t: clang.CXType) -> ^types.Type {
    output := new(types.Type)
    // fmt.println(type_spelling(t))
    // output.name = 
    #partial switch t.kind {
        // case .CXType_FunctionProto: {
        //     output.variant = build_function_type(t)
        // }
        // Check if I need to handle special case for function pointers
        case .CXType_Pointer: {
            // output.variant = build_ptr_type(t)
        }
        case .CXType_Void: {
            output.variant = types.Primitive{types.Primitive_Kind.void}
        }
        case .CXType_Char_S: {
            output.variant = types.Primitive{types.Primitive_Kind.schar}
        }
        case .CXType_Int: {
            output.variant = types.Primitive{types.Primitive_Kind.int}
        }
        case .CXType_Elaborated: {
            // cursor := clang.getTypeDeclaration(t)
            // // Free previous data
            // found := cached_cursors[clang.hashCursor(cursor)]
            // output.variant = types.Node_Ref{found}
        }
        case: fmt.println(t.kind)
    }
    return output
}

// visit_typedef :: proc(cursor: clang.CXCursor) -> types.Typedef {
//     t := clang.getTypedefDeclUnderlyingType(cursor)
//     base := type_(t)
//     name := type_spelling(t)
//     cached_cursors[clang.hashCursor(cursor)] = base
//     return types.Typedef{name,base}
// }

visit_function_decl :: proc(s: ^State, cursor: clang.CXCursor) -> types.Func {

}

visit :: proc (s: ^State, cursor: clang.CXCursor) ->^types.Type {
    output := new(types.Type)
    // fmt.println(cursor_spelling(cursor))
    output.name = spelling(cursor)
    // fmt.println(output.name)
    #partial switch cursor.kind {
        case .CXCursor_FunctionDecl: 
            output.variant = visit_function_decl(s, cursor)
        // case .CXCursor_TypedefDecl: {
        //     output.variant = visit_typedef(cursor)
        // }
    }
    return output
}

parse :: proc() -> []^types.Type {
    idx := clang.createIndex(0, 1);
    defer clang.disposeIndex(idx)

    content: cstring = "#include \"test/headers.h\""
    file := clang.CXUnsavedFile {
        Filename = "test.c",
        Contents = content,
        Length = auto_cast len(content),
    }
    files := []clang.CXUnsavedFile{file}
    raw_flags := "-I/usr/include/python3.8 -I/usr/include/python3.8  -Wno-unused-result -Wsign-compare -g -fdebug-prefix-map=/build/python3.8-4OrTnN/python3.8-3.8.10=. -specs=/usr/share/dpkg/no-pie-compile.specs -fstack-protector -Wformat -Werror=format-security  -DNDEBUG -g -fwrapv -O3 -Wall -lcrypt -lpthread -ldl  -lutil -lm -lm"

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
        fmt.println(err)
    }
    if tu == nil {
        fmt.println("Failed to configure translation unit")
        os.exit(1)
    }
    cursor := clang.getTranslationUnitCursor(tu)
    // TODO:
    // remove this later if everything works as expected
    
    default_allocator: = context.allocator
    state := make_state(&default_allocator)

    clang.visitChildren(cursor, proc "c" (
        cursor: clang.CXCursor,
        parent: clang.CXCursor,
        client_data: clang.CXClientData,
    ) -> clang.CXChildVisitResult {

        state := (^State)(client_data)
        context = runtime.default_context()
        context.allocator = state.allocator^
        
        visit(cursor)
    
        return clang.CXChildVisitResult.CXChildVisit_Continue;
    }, state)
    
    // for value in state.test {
    //     fmt.println(value)
    // }

    return state.declared[:]
}