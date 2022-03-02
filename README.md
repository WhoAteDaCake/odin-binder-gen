* https://juliainterop.github.io/Clang.jl/stable/tutorial/
* https://github.com/clibs/clib/wiki/Packages
    * Libraries to test against
* https://github.com/crystal-lang/clang.cr/blob/d019b9ff105cd652f31cca73e950adbf41037d52/src/translation_unit.cr
    * `CXUnsavedFile` should be used later

TODO:
* Optimise structs and enums, if one without name is found, the first time we find a typedef, that could claim it the enum or struct. 
* Add built in types like timeval,tm,stat
    * Look up from the previous scripts
* Incomplete array size has 0 size, need to update in stringify

Doing:
* Function type implementation
