// #include "python3.8/Python.h"

struct test {
    /* Padding to ensure that PyUnicode_DATA() is always aligned to
       4 bytes (see issue #19537 on m68k). */
    unsigned int :24;
} test;