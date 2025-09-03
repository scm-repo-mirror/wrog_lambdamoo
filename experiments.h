/******************************************************************************
  Copyright (c) 2025  Roger F. Crew.  All rights reserved.

  Because there is so much important intellectual property here:

  This one specific file is licensed under the
  You Will Pry This File Out Of My Cold Dead Hands License,
  Version 1.

  This software is made available AS IS, and no warranty is made about
  the software, its performance or its conformity to any specification.
  Derivative works including this file verbatim are allowed.
  Entirely omitting this file is also allowed.
*/

/* Experimenting
 *
 * This module does not currently need a header, but I decided to
 * write one to illustrate a few C coding practices that I thought
 * everybody already knew, but apparently not.
 */

/*\ Random explanatory meta-comments look like this to distinguish
 *| from stuff that has been commented out or comments you might
 *| want to have in a Real File.
 */

/*\ First thing, VERY IMPORTANT:
 *|
 *| This is a .h file.  There must be an #ifndef around everything,
 *| so that if multiple #includes for this file are encountered,
 *| the compiler only sees the actual content of the file exactly once.
 *| I don't care how stupid and small the file is, do this anyway.
 *| Small files will nearly always get bigger than you ever expected.
 *| (How could people have NOT known to do this?  in 1999?)
 */
#ifndef Experiments_H
#define Experiments_H 1
/*\
 *| Presenting our Completely Arbitrary Rules for forming the symbol
 *| from the filename:
 *|
 *| (1)  Capitalize each word of the filename,
 *| (2)  The final 'H' is capitalized, *unless*
 *|      the rest of the filename is an initialism (AST, DB)
 *|      which would make the resulting symbol all-caps (AST_H, DB_H)
 *|      which we do not want (since it might collide with something real)
 *|      so use a small 'h' in those cases (AST_h, DB_h)
 *| (3)  Make certain this preprocessor symbol is used NOWHERE ELSE.
 *|      We do not want ANY surprises.
 */


/*\ 1st block of includes for a .h file:  config and options
 *| These can be omitted if no declaration makes any references to any
 *| config or option settings.  There's an argument for being conservative
 *| re .h file #includes, since .h files potentially show up everywhere.
 *| Then again, config.h and options.h are intended to be harmless and
 *| really do have to show up everywhere.
 *|
 *| In any case, if you include them they HAVE to be first.
 */

/* #include "config.h"  */
/* #include "options.h" */

/*\ 2nd block of includes for a .h file:
 *| Any system-corrective header files that are needed (and *only* those).
 */

/* #include "my-ctype.h"    */
/* #include "my-fcntl.h"    */
/* #include "my-in.h"       */
/* #include "my-inet.h"     */
/* #include "my-ioctl.h"    */
/* #include "my-math.h"     */
/* #include "my-poll.h"     */
/* #include "my-signal.h"   */
/* #include "my-socket.h"   */
/* #include "my-stat.h"     */
/* #include "my-stdarg.h"   */
/* #include "my-stdio.h"    */
/* #include "my-stdlib.h"   */
/* #include "my-string.h"   */
/* #include "my-stropts.h"  */
/* #include "my-sys-time.h" */
/* #include "my-time.h"     */
/* #include "my-tiuser.h"   */
/* #include "my-types.h"    */
/* #include "my-unistd.h"   */
/* #include "my-wait.h"     */

/*\ 3rd block of includes for a .h file:
 *| Whatever other headers are needed.  Here, you definitely want to be
 *| conservative.  (The .c file will doubtless need all manner of
 *| random things; let the .c file do what it wants; nobody will care.)
 *|
 *| Also, do not forget that C not only allows forward references for
 *| functions, but also completely undefined structs and unions.
 *| Best way to do abstract datatypes in C, just in case you were
 *| wondering:
 *|
 *|     typedef struct my_thing *MyThing;
 *|
 *| You can use MyThing all over and there will be no complaints
 *| as long as you never dereference it (which you won't be doing
 *| anywhere outside of the file that implements MyThing, right?).
 *| And what's really cool is the compiler will typecheck it for you
 *| since pointers to different kinds of undefined structs will never
 *| be equivalent.  No need for unsafe crap with void*.
 *| (TODO:  fix how network and server handles work here,
 *|         presently a good example of how NOT to do ADTs in C.)
 *|
 *| Meanwhile for ordering #includes, alphbetical is fine.
 *| The most any human will be doing with these lists is looking to
 *| see if a particular file is already mentioned, in which case she
 *| will want to be able to find it quickly.
 */

/* #include "ast.h" 	    */
/* #include "code_gen.h"    */
/* #include "db.h" 	    */
/* #include "db_io.h" 	    */
/* #include "db_private.h"  */
/* #include "db_tune.h"     */
/* #include "decompile.h"   */
/* #include "disassemble.h" */
/* #include "eval_env.h"    */
/* #include "eval_vm.h"     */
/* #include "exceptions.h"  */
/* #include "execute.h"     */
/* #include "functions.h"   */
/* #include "getpagesize.h" */
/* #include "keywords.h"    */
/* #include "list.h" 	    */
/* #include "log.h" 	    */
/* #include "match.h" 	    */
/* #include "md5.h" 	    */
/* #include "name_lookup.h" */
/* #include "net_mplex.h"   */
/* #include "net_multi.h"   */
/* #include "net_proto.h"   */
/* #include "network.h"     */
/* #include "numbers.h"     */
/* #include "opcode.h" 	    */
/* #include "parse_cmd.h"   */
/* #include "parser.h" 	    */
/* #include "pattern.h"     */
/* #include "program.h"     */
/* #include "quota.h" 	    */
/* #include "random.h" 	    */
/* #include "ref_count.h"   */
/* #include "server.h" 	    */
/* #include "storage.h"     */
/* #include "str_intern.h"  */
/* #include "streams.h"     */
/* #include "structures.h"  */
/* #include "sym_table.h"   */
/* #include "tasks.h" 	    */
/* #include "timers.h" 	    */
/* #include "tokens.h" 	    */
/* #include "unparse.h"     */
/* #include "utf-ctype.h"   */
/* #include "utf.h" 	    */
/* #include "utils.h" 	    */
/* #include "verbs.h" 	    */
/* #include "version.h"     */
/* #include "waif.h" 	    */

/*\ And now for actual content, even if there isn't any.
 */

/*\ (1) Structure and Type declarations
 */

/*\ (2) Function declarations
 */

/*\ Or, if there's some reasonable subdivision by topics, you could do
 *| that, too.  But the above plan is where people expect to find
 *| things and they'll thank you if they can find them quickly.
 */

/*\
 *| Finally, the all important #endif (do NOT forget the comment,
 *| especially since the #ifndef happened SO long ago...):
 */
#endif		/* !Experiments_H */

/*\ Follow with any less-important blocks of final commentary,
 *| poltical ramblings, and notes for your next SF novel in which you
 *| have inserted yourself as an awesome Mary Sue character who
 *| saves the universe.  We love those; you should do more of them.
 */

/*\ Any new file should end here, i.e.,
 *| DO NOT DO ANY OF THE FOLLOWING
 *| (The year is now 2025.  The future has arrived.  We have git.
 *|  CVS is deader than a doornail.  Are we done, yet?):
 */

/* char rcsid_experiments[] = "$Id$"; */

/*
 * $Log$
 */
/*\ Yes, for files that existed prior to 1997 we like keeping the CVS
 *| log entries around because they give us warm nostalgia fuzzies and
 *| because this is the one bit of historical information not available
 *| in git.  But anything new you are writing won't have this.
 */

/*\ Okay, **now**, I'm done.  Unless you haven't read experiments.c yet.
 */
