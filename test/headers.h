
#include <wchar.h>

// #include "python3.8/Python.h"
int _Py_wreadlink(
    const wchar_t *path,
    wchar_t *buf,
/* Number of characters of 'buf' buffer
    including the trailing NUL character */
    size_t buflen);