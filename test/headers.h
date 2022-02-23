
// #include <stdbool.h>
// #include <stdio.h>

// /*
//  * Max flags that may be defined.
//  */

// #define FLAGS_MAX 128

// /*
//  * Max arguments supported for set->argv.
//  */

// #define FLAGS_MAX_ARGS 128

// /*
//  * Flag errors.
//  */

// typedef enum {
//   FLAG_OK,
//   FLAG_ERROR_PARSING,
//   FLAG_ERROR_ARG_MISSING,
//   FLAG_ERROR_UNDEFINED_FLAG
// } flag_error;

// /*
//  * Flag types supported.
//  */

// typedef enum {
//   FLAG_TYPE_INT,
//   FLAG_TYPE_BOOL,
//   FLAG_TYPE_STRING
// } flag_type;

// /*
//  * Flag represents as single user-defined
//  * flag with a name, help description,
//  * type, and pointer to a value which
//  * is replaced upon precense of the flag.
//  */

// typedef struct {
//   const char *name;
//   const char *help;
//   flag_type type;
//   void *value;
// } flag_t;

// /*
//  * Flagset contains a number of flags,
//  * and is populated wth argc / argv with the
//  * remaining arguments.
//  *
//  * In the event of an error the error union
//  * is populated with either the flag or the
//  * associated argument.
//  */

// typedef struct {
//   const char *usage;
//   int nflags;
//   flag_t flags[FLAGS_MAX];
// //   int argc;
// //   const char *argv[FLAGS_MAX_ARGS];
// //   union {
// //     flag_t *flag;
// //     const char *arg;
// //   } error;
// } flagset_t;
typedef struct {
    int flags[20];
} flag_item;