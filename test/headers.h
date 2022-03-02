#include "python3.8/Python.h"
  

// typedef struct _typeobject {
//     // Strong reference on a heap type, borrowed reference on a static type
//     // struct _typeobject *tp_base;
//     int tp_basicsize, tp_itemsize; /* For allocation */
// } PyTypeObject;
// typedef struct _object {
//     _PyObject_HEAD_EXTRA
//     Py_ssize_t ob_refcnt;
//     PyTypeObject *ob_type;
//     struct _object *_ob_next;
//     struct _object *_ob_prev;
// } PyObject;