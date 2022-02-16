// https://github.com/Breush/odin-binding-generator/blob/master/tests/parsing/headers/source.h

// https://github.com/Breush/odin-binding-generator/issues/16
// typedef int cookie_read_function_t(void *__cookie, char *__buf, int __nbytes);
// typedef struct _IO_cookie_io_functions_t {
//   cookie_read_function_t *read;
// } cookie_io_functions_t;

int cookie_read_function_t(void *__cookie, char *__buf, int __nbytes);