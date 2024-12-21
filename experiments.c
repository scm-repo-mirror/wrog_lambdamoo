/******************************************************************************
  Copyright (c) 1995, 1996 Xerox Corporation.  All rights reserved.
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

/* Experimenting

 * This module contains an example of how to add functionality to the
 * MOO server using interfaces exported by various other modules.  The
 * example itself is commented out, since it's really not all that
 * useful in general; it was written primarily to test out the
 * interfaces it uses.
 *
 * The uncommented parts of this module provide one possible skeleton
 * for a module that implements new MOO built-in functions.  Replacing
 * the commented-out parts is a quick way to try out your own function
 * definitions.  In future releases, this file will be kept as a
 * convenient place to experiment with new server functionality; it
 * will not contain any live code that the server actually depends on,
 * or, rather, nothing beyond the register_experiments() function with
 * its #ifdef-ed out body that *does*, in fact, get called on every
 * server startup even though it does nothing by default (i.e.,
 * assuming you leave it unmodified).
 *
 * (note: This file *was* originally named extensions.c, but has since
 *  been renamed to better reflect its role as a playground now that
 *  (25 years later) there is a somewhat more developed extension
 *  framework and with more thought put into how extensions should be
 *  defined, behave, and interact with each other in the server
 *  context.  See extensions.txt for what you need to know once you
 *  are ready to migrate code *out* of this file and into an actual
 *  extension.)
 */

#define EXAMPLE 0

#include "bf_register.h"
#include "functions.h"

#if EXAMPLE

#include "my-unistd.h"

#include "exceptions.h"
#include "log.h"
#include "net_multi.h"
#include "storage.h"
#include "tasks.h"

typedef struct stdin_waiter {
    struct stdin_waiter *next;
    vm the_vm;
} stdin_waiter;

static stdin_waiter *waiters = 0;

static task_enum_action
stdin_enumerator(task_closure closure, void *data)
{
    stdin_waiter **ww;

    for (ww = &waiters; *ww; ww = &((*ww)->next)) {
	stdin_waiter *w = *ww;
	const char *status = (w->the_vm->task_id & 1
			      ? "stdin-waiting"
			      : "stdin-weighting");
	task_enum_action tea = (*closure) (w->the_vm, status, data);

	if (tea == TEA_KILL) {
	    *ww = w->next;
	    myfree(w, M_TASK);
	    if (!waiters)
		network_unregister_fd(0);
	}
	if (tea != TEA_CONTINUE)
	    return tea;
    }

    return TEA_CONTINUE;
}

static void
stdin_readable(int fd, void *data)
{
    char buffer[1000];
    int n;
    Var v;
    stdin_waiter *w;

    if (data != &waiters)
	panic("STDIN_READABLE: Bad data!");

    if (!waiters) {
	errlog("STDIN_READABLE: Nobody cares!\n");
	return;
    }
    n = read(0, buffer, sizeof(buffer));
    buffer[n] = '\0';
    while (n)
	if (buffer[--n] == '\n')
	    buffer[n] = 'X';

    if (buffer[0] == 'a') {
	v.type = TYPE_ERR;
	v.v.err = E_NACC;
    } else {
	v.type = TYPE_STR;
	v.v.str = str_dup(buffer);
    }

    resume_task(waiters->the_vm, v);
    w = waiters->next;
    myfree(waiters, M_TASK);
    waiters = w;
    if (!waiters)
	network_unregister_fd(0);
}

static enum error
stdin_suspender(vm the_vm, void *data)
{
    stdin_waiter *w = data;

    if (!waiters)
	network_register_fd(0, stdin_readable, 0, &waiters);

    w->the_vm = the_vm;
    w->next = waiters;
    waiters = w;

    return E_NONE;
}

static package
bf_read_stdin(Var arglist, Byte next, void *vdata, Objid progr)
{
    stdin_waiter *w = mymalloc(sizeof(stdin_waiter), M_TASK);

    return make_suspend_pack(stdin_suspender, w);
}
#endif				/* EXAMPLE */

void
register_experiments(void)
{
#if EXAMPLE
    register_task_queue(stdin_enumerator);
    register_function("read_stdin", 0, 0, bf_read_stdin);
#endif
}


/*
 * $Log$
 * Revision 2.1  1996/02/08  07:03:47  pavel
 * Renamed err/logf() to errlog/oklog().  Updated copyright notice for 1996.
 * Release 1.8.0beta1.
 *
 * Revision 2.0  1995/11/30  04:26:34  pavel
 * New baseline version, corresponding to release 1.8.0alpha1.
 *
 * Revision 1.1  1995/11/30  04:26:21  pavel
 * Initial revision
 */
