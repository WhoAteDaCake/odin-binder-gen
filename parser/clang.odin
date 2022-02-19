package parser

import "core:strings"
import "core:slice"
import "core:fmt"
import "core:os"
import "core:runtime"

import clang "../odin-clang"

CursorAction :: proc(s: ^State, cursor: clang.CXCursor) -> clang.CXChildVisitResult

WrappedState :: struct {
    state: ^State,
    action: CursorAction,
}

visit_children :: proc(
    state: ^State,
    cursor: clang.CXCursor,
    action: CursorAction,
) {
    wrapped := WrappedState{state, action}
    clang.visitChildren(cursor, proc "c" (
        cursor: clang.CXCursor,
        parent: clang.CXCursor,
        client_data: clang.CXClientData,
    ) -> clang.CXChildVisitResult {

        w_state := (^WrappedState)(client_data)
        context = runtime.default_context()
        context.allocator = w_state.state.allocator^
        
        return w_state.action(w_state.state, cursor)
    }, &wrapped)
}