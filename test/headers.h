// #include "python3.8/Python.h"
  
typedef struct _typeobject {
    // Strong reference on a heap type, borrowed reference on a static type
    struct _typeobject *tp_base;
} PyTypeObject;