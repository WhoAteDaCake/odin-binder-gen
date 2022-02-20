package types

core_c_builtins :: [?]string{
    "char",
    "schar",
    "short",
    "int",
    "long",
    "longlong",
    "uchar",
    "ushort",
    "uint",
    "ulong",
    "ulonglong",
    "bool",
    "size_t",
    "ssize_t",
    "wchar_t",
    "float",
    "double",
    "complex_float",
    "complex_double",
    "int8_t",
    "uint8_t",
    "int16_t",
    "uint16_t",
    "int32_t",
    "uint32_t",
    "int64_t",
    "uint64_t",
    "int_least8_t",
    "uint_least8_t",
    "int_least16_t",
    "uint_least16_t",
    "int_least32_t",
    "uint_least32_t",
    "int_least64_t",
    "uint_least64_t",
    "int_fast8_t",
    "uint_fast8_t",
    "int_fast16_t",
    "uint_fast16_t",
    "int_fast32_t",
    "uint_fast32_t",
    "int_fast64_t",
    "uint_fast64_t",
    "intptr_t",
    "uintptr_t",
    "ptrdiff_t",
    "intmax_t",
    "uintmax_t",
}

is_builtin :: proc(t: string) -> bool {
    for b in core_c_builtins {
        if b == t {
            return true
        }
    }
    return false
}