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

# --(enable|disable)-{extensions}
MOO_XT_EXTENSION_ARGS()

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

# --(enable|disable)-svf-*  for server-version-full settings
MOO_SVF_ARG_ENABLES()

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
AC_DEFUN([MOO_PUT_HELP],
[m4_divert_text([HELP_$1],[$2])])
