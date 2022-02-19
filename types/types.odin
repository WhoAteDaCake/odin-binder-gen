package types

TypeVariant :: union{
    Invalid,
    Primitive,
    Typedef,
    Pointer,
    Array,
    Func,
    Struct,
    Union,
    Va_Arg,
    Node_Ref,
    FieldDecl,
}

Type :: struct
{
    name: string,
    variant: TypeVariant,
}

Va_Arg :: struct {}

Invalid :: struct{}

Primitive :: struct
{
    type_: string,
    ctype: bool,
}

Node_Ref :: struct {
    base: ^Type,
}

Typedef :: struct
{
    name: string,
    base: ^Type,
}

Func :: struct
{
    variadic: bool,
    ret: ^Type,
    params: []^Type,
}

FieldDecl :: struct {
    name: string,
    type_: ^Type, 
}

Pointer :: struct
{
    base: ^Type,
}

Struct :: struct
{
    fields: []^Type,
}

Union :: struct
{
    fields: []^Type,
}

Array :: struct
{
    base: ^Type,
    size: i64,
}

primitive_by_name :: proc(name: string) -> Primitive {
    return Primitive{name, true,}
}

primitive_by_name_c_type :: proc(name: string, ctype: bool) -> Primitive {
    return Primitive{name, ctype,}
}

primitive :: proc{primitive_by_name, primitive_by_name_c_type}