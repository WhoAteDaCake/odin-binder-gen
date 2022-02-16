package parser

import clang "../odin-clang"


cursor_spelling :: proc (item: clang.CXCursor) -> string {
    spelling := clang.getCursorSpelling(item)
    return string(clang.getCString(spelling))
}

cursor_kind_spelling :: proc (item: clang.CXCursorKind) -> string {
    spelling := clang.getCursorKindSpelling(item)
    return string(clang.getCString(spelling))
}

type_spelling :: proc (item: clang.CXType) -> string {
    spelling := clang.getTypeSpelling(item)
    return string(clang.getCString(spelling))
}

kind_spelling :: proc (item: clang.CXTypeKind) -> string {
    spelling := clang.getTypeKindSpelling(item)
    return string(clang.getCString(spelling))
}

spelling :: proc {
    cursor_spelling,
    cursor_kind_spelling,
    type_spelling,
    kind_spelling,
}

