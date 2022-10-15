dnl  -*- autoconf -*-
dnl

# --------------------------------------------------------------------
#  MOO_ALL_ARGUMENTS()
#
#  creates all of the MOO-specific --enable-* and --with-* arguments
#  for ./configure

AC_DEFUN([MOO_ALL_ARGUMENTS],

[AC_PRESERVE_HELP_ORDER()dnl
#----------------------------------------------------
#  process LambdaMOO-specific command-line arguments
#----------------------------------------------------

# --(enable|disable)-net
MOO_NET_ARG_ENABLE([net])

# --(enable|disable)-prop-protect
#   a less insane way of dealing with IGNORE_PROP_PROTECTED
dnl
dnl This is here as an example of how to do optional features
dnl that are less complicated than --enable-net
dnl
AC_ARG_ENABLE([prop-protect],[
AS_HELP_STRING([--disable-prop-protect],[disable])
AS_HELP_STRING([--enable-prop-protect],[/enable  protection of builtin properties])],
[AS_CASE([$enableval],
  [no],[[moo_d_IGNORE_PROP_PROTECTED=yes]],
  [[moo_d_IGNORE_PROP_PROTECTED=no]])])

# --(enable|disable)-def-*  for options.h settings
MOO_OPTION_ARG_ENABLES()dnl
# -- end of moo-specific (enable|disable)

MOO_PUT_HELP([ENABLE],[
Other Features:])])
dnl
dnl --- end of MOO_ALL_ARGUMENTS

# ------------------------------------------------------------------
#  MOO_PUT_HELP(OPTIONGRP,TEXT)
#
#  With OPTIONGRP being either 'ENABLE' or 'WITH',
#  inserts additional TEXT into that section of ./configure help
#  (to break up the list and make it more readable).
#
#  TEXT must be different from all other instances of
#  --enable/--with help text, because under the hood 'm4_divert_once'
#  is being used.  So, e.g., if you were to use TEXT=[\n] several times,
#  all but the first will be ignored.
#
dnl  (This works by adding an extra unreachable bogus option,
dnl   which, admittedly, relies on the --enable/--with options
dnl   being kept in order, which *seems* to be a promise...)
dnl
AC_DEFUN([MOO_PUT_HELP],
[AC_ARG_][$1]([[undocu]moo_put_help_counter()[mented-option-that-does-nothing]],[[$2]]))

m4_define([moo_put_help_counter],
[m4_define([_$0],m4_incr(m4_defn([_$0])))dnl
m4_format([[%03d]],m4_defn([_$0]))])

m4_define([_moo_put_help_counter],[0])
