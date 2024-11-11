/******************************************************************************
  Copyright (c) 1992, 1995, 1996 Xerox Corporation.  All rights reserved.
  Portions of this code were written by Stephen White, aka ghond.
  Use and copying of this software and preparation of derivative works based
  upon this software are permitted.  Any distribution of this software or
  derivative works must comply with all applicable United States export
  control laws.  This software is made available AS IS, and Xerox Corporation
  makes no warranty about the software, its performance or its conformity to
  any specification.  Any person obtaining a copy of this software is requested
  to send their name and post office or electronic mail address to:
    Pavel Curtis
    Xerox PARC
    3333 Coyote Hill Rd.
    Palo Alto, CA 94304
    Pavel@Xerox.Com
 *****************************************************************************/

#ifndef Structures_H
#define Structures_H 1

#include "config.h"

#include "my-math.h"
#include "my-stdio.h"
#include "my-stdlib.h"


/***********
 * Integers
 */

/* This will move to options.h */
#define INT_TYPE_BITSIZE 32

typedef int32_t   Num;
typedef uint32_t UNum;
#define PRIdN	PRId32
#define PRIuN	PRIu32
#define SCNdN	SCNd32
#define SCNuN	SCNu32
#define NUM_MAX	INT32_MAX
#define NUM_MIN	INT32_MIN

#if HAVE_INT64_T
/*
 *  I was originally going to insist 'Num' be called something else,
 *  but I decided to let that go.  This is your pennance:    --wrog
 */
#  define HAVE_UNUMNUM_T 1
typedef  int64_t   NumNum;
typedef uint64_t  UNumNum;
#endif


/***********
 * Objects
 *
 * Note:  It's a pretty hard assumption in MOO that integers and objects
 * are the same data type.
 */

typedef Num     Objid;
#define OBJ_MAX	NUM_MAX

/*
 * Special Objid's
 */
#define SYSTEM_OBJECT	0
#define NOTHING		-1
#define AMBIGUOUS	-2
#define FAILED_MATCH	-3


/***************
 * Floats
 */

#define PRIeR "e"
#define PRIfR "f"
#define PRIgR "g"

/* for now */
#define FLOATS_ARE_BOXED 1

typedef  double  FlNum;
#define FLOAT_FN(name)  name
#define FLOAT_DEF(name) name
#define FLOAT_DIGITS    DBL_DIG
#define strtoflnum      strtod

#if !FLOATS_ARE_BOXED

typedef FlNum  FlBox;
inline  FlNum  fl_unbox(FlBox p) { return p; }
inline  FlBox  box_fl(  FlNum f) { return f; }

#else   /* FLOATS_ARE_BOXED */

typedef FlNum *FlBox;
inline  FlNum  fl_unbox(FlBox p) { return *p; }
extern  FlBox  box_fl(  FlNum f);

#endif	/* FLOATS_ARE_BOXED */


/***********
 * Errors
 */

/* Do not reorder or otherwise modify this list, except to add new elements at
 * the end, since the order here defines the numeric equivalents of the error
 * values, and those equivalents are both DB-accessible knowledge and stored in
 * raw form in the DB.
 */
#define ERR_SPEC_LIST(DEF)				\
    DEF(E_NONE,    "No error")				\
    DEF(E_TYPE,    "Type mismatch")			\
    DEF(E_DIV,     "Division by zero")			\
    DEF(E_PERM,    "Permission denied")			\
    DEF(E_PROPNF,  "Property not found")		\
    DEF(E_VERBNF,  "Verb not found")			\
    DEF(E_VARNF,   "Variable not found")		\
    DEF(E_INVIND,  "Invalid indirection")		\
    DEF(E_RECMOVE, "Recursive move")			\
    DEF(E_MAXREC,  "Too many verb calls")		\
    DEF(E_RANGE,   "Range error")			\
    DEF(E_ARGS,    "Incorrect number of arguments")	\
    DEF(E_NACC,    "Move refused by destination")	\
    DEF(E_INVARG,  "Invalid argument")			\
    DEF(E_QUOTA,   "Resource limit exceeded")		\
    DEF(E_FLOAT,   "Floating-point arithmetic error")	\

#define ERROR_DO_(E_NAME,_2)  E_NAME,
enum error {
    ERR_SPEC_LIST(ERROR_DO_)
    ERR_COUNT,
    ERR_MAX = ERR_COUNT - 1,
    ERR_MIN = E_NONE
};
#undef ERROR_DO_


/***********
 * Task IDs
 *
 * Since task ID numbers occur in MOO-code,
 * this datatype must either be Num or a subrange.
 */

/* (negative taskIDs are deemed Bad but i don't know why. --wrog) */
#define TASK_MIN 0

#if INT32_MAX < NUM_MAX

/* Admittedly, the extra space taken up by int64_t task ids
 * would not kill us, but are we ever really going to get
 * to a billion+ tasks in a single server run?  Survey sez NO.
 */
typedef  int32_t    TaskID;
#  define PRIdT	    PRId32
#  define SCNdT     SCNd32
#  define TASK_MAX  INT32_MAX

/* This is only used for searching */
inline TaskID task_id_from_num(Num n) {
    return (TaskID)(n < 0 || n > INT32_MAX ? 0 : n);
}

#else
typedef   Num       TaskID;
#  define PRIdT	    PRIdN
#  define SCNdT     SCNdN
#  define TASK_MAX  NUM_MAX

inline TaskID task_id_from_num(Num n) {
    return n < 0 ? 0 : n;
}
#endif

inline Num num_from_task_id(TaskID t) { return t; }

/* typedef struct task_id_ *TaskID;
inline TaskID task_id_from_num(Num n) { return (TaskID)(void *)(uintmax_t)n; }
inline Num num_from_task_id(TaskID t) { return (Num)(uintmax_t)(void *)t; }
 */


/****************
 * General Types
 */

/* Types which have external data should be marked with the TYPE_COMPLEX_FLAG
 * so that free_var/var_ref/var_dup can recognize them easily.  This flag is
 * only set in memory.  The original _TYPE values are used in the database
 * file and returned to verbs calling typeof().  This allows the inlines to
 * be extremely cheap (both in space and time) for simple types like oids
 * and ints.
 */
#define TYPE_DB_MASK		0x7f
#define TYPE_COMPLEX_FLAG	0x80

/* Do not reorder or otherwise modify the first part of this list
 * (up to "add new elements here"), since the order here defines the
 * numeric equivalents of the type values, and those equivalents are both
 * DB-accessible knowledge and stored in raw form in the DB.
 */
typedef enum {
    TYPE_INT, TYPE_OBJ, _TYPE_STR, TYPE_ERR, _TYPE_LIST, /* user-visible */
    TYPE_CLEAR,			/* in clear properties' value slot */
    TYPE_NONE,			/* in uninitialized MOO variables */
    TYPE_CATCH,			/* on-stack marker for an exception handler */
    TYPE_FINALLY,		/* on-stack marker for a TRY-FINALLY clause */
    _TYPE_FLOAT,		/* floating-point number; user-visible */
    /* add new elements here */

    TYPE_STR   = (_TYPE_STR   | TYPE_COMPLEX_FLAG),
    TYPE_LIST  = (_TYPE_LIST  | TYPE_COMPLEX_FLAG),
    TYPE_FLOAT = (_TYPE_FLOAT
#if FLOATS_ARE_BOXED
		  | TYPE_COMPLEX_FLAG
#endif
		  ),

    TYPE_ANY     = -1,	/* wildcard for use in declaring built-ins */
    TYPE_NUMERIC = -2	/* wildcard for (integer or float) */
} var_type;


/***********
 * Experimental.  On the Alpha, DEC cc allows us to specify certain
 * pointers to be 32 bits, but only if we compile and link with "-taso
 * -xtaso" in CFLAGS, which limits us to a 31-bit address space.  This
 * could be a win if your server is thrashing.  Running JHM's db, SIZE
 * went from 50M to 42M.  No doubt these pragmas could be applied
 * elsewhere as well, but I know this at least manages to load and run
 * a non-trivial db.
 *
 * ( History update:  Previous appears to be from Jay, circa 1997.
 *
 *   In the early 2000s, DEC Alpha was killed off.  It also seems the
 *   pointer_size pragma never caught on outside of DEC.  However,
 *   OpenVMS is evidently A Thing now, or at least as recently as
 *   2019, and its gcc/clang seems to know about pointer_size, so
 *   there remains a remote possibility that this still works
 *   (or, at least, can be made to work) somewhere.
 *
 *   pragmas were originally placed immediately surrounding struct
 *   Var, but they also included struct Waif on the waif branch,
 *   presumably deliberately.  To get this out of the way, I have
 *   moved it backwards into its own section... presumably safe
 *   since it should only affect struct/pointer declarations.
 *        --wrog      )
 *
  ................................
  :  begin DEC ALPHA experiment  :
  :
  :   #define SHORT_ALPHA_VAR_POINTERS 1
  */
#ifdef SHORT_ALPHA_VAR_POINTERS
#pragma pointer_size save
#pragma pointer_size short
#endif


/*********
 * Vars
 */

typedef struct Var Var;

struct Var {
    union {
	const char *str;	/* STR */
	Num num;		/* NUM, CATCH, FINALLY */
	Objid obj;		/* OBJ */
	enum error err;		/* ERR */
	Var *list;		/* LIST */
	FlBox fnum;		/* FLOAT */
    } v;
    var_type type;
};

extern Var zero;		/* useful constant */


#ifdef SHORT_ALPHA_VAR_POINTERS
#pragma pointer_size restore
#endif
/*
 :  end of DEC ALPHA experiment  :
 :...............................:*/

#endif		/* !Structures_H */


/*
 * $Log$
 * Revision 2.1  1996/02/08  06:12:21  pavel
 * Added E_FLOAT, TYPE_FLOAT, and TYPE_NUMERIC.  Renamed TYPE_NUM to TYPE_INT.
 * Updated copyright notice for 1996.  Release 1.8.0beta1.
 *
 * Revision 2.0  1995/11/30  04:55:46  pavel
 * New baseline version, corresponding to release 1.8.0alpha1.
 *
 * Revision 1.12  1992/10/23  23:03:47  pavel
 * Added copyright notice.
 *
 * Revision 1.11  1992/10/21  03:02:35  pavel
 * Converted to use new automatic configuration system.
 *
 * Revision 1.10  1992/09/14  17:40:51  pjames
 * Moved db_modification code to db modules.
 *
 * Revision 1.9  1992/09/04  01:17:29  pavel
 * Added support for the `f' (for `fertile') bit on objects.
 *
 * Revision 1.8  1992/09/03  16:25:12  pjames
 * Added TYPE_CLEAR for Var.
 * Changed Property definition lists to be arrays instead of linked lists.
 *
 * Revision 1.7  1992/08/31  22:25:04  pjames
 * Changed some `char *'s to `const char *'
 *
 * Revision 1.6  1992/08/14  00:00:36  pavel
 * Converted to a typedef of `var_type' = `enum var_type'.
 *
 * Revision 1.5  1992/08/10  16:52:00  pjames
 * Moved several types/procedure declarations to storage.h
 *
 * Revision 1.4  1992/07/30  21:24:31  pjames
 * Added M_COND_ARM_STACK and M_STMT_STACK for vector.c
 *
 * Revision 1.3  1992/07/28  17:18:48  pjames
 * Added M_COND_ARM_STACK for unparse.c
 *
 * Revision 1.2  1992/07/27  18:21:34  pjames
 * Changed name of ct_env to var_names, const_env to literals and
 * f_vectors to fork_vectors, removed M_CT_ENV, M_LOCAL_ENV, and
 * M_LABEL_MAPS, changed M_CONST_ENV to M_LITERALS, M_IM_STACK to
 * M_EXPR_STACK, M_F_VECTORS to M_FORK_VECTORS, M_ID_LIST to M_VL_LIST
 * and M_ID_VALUE to M_VL_VALUE.
 *
 * Revision 1.1  1992/07/20  23:23:12  pavel
 * Initial RCS-controlled version.
 */
