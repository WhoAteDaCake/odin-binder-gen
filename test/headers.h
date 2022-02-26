// #include "deps/flag/flag.h"

// #include <stdbool.h>
// #include <stdio.h>

// typedef bool test_bool;

// void
// flagset_bool(int *self, bool *value, const char *name, const char *help);
typedef int cookie_read_function_t(void *__cookie, char *__buf, int __nbytes);
// typedef struct _IO_cookie_io_functions_t {
//   cookie_read_function_t *read;
// } cookie_io_functions_t;