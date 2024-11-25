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

# --enable-sz
MOO_DATATYPESIZE_ARG_ENABLE([sz])

# --(enable|disable)-{extensions}
MOO_XT_EXTENSION_ARGS()

# --(enable|disable)-prop-protect
#   a less insane way of dealing with IGNORE_PROP_PROTECTED
dnl
dnl This is here as an example of how to do optional features
dnl that are less complicated than --enable-net|sz|...
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

# ------------------------------------------------------------------
#  MOO_DATATYPESIZE_ARG_ENABLE([<data_type_size>])
#    creates the --enable-<data_type_size>=kwds... ./configure argument
#
AC_DEFUN([MOO_DATATYPESIZE_ARG_ENABLE],
[AC_ARG_ENABLE([$1],[[
 Datatype options:]
AS_HELP_STRING([[--enable-$1=KWD[,KWD]]],
[set all datatype size options])
[               i64, i32, i16:  INT_TYPE_BITSIZE=*]
[     flt, fdbl, flong, fquad:  FLOATING_TYPE=FT_*]
[                  box, unbox:  BOXED_FLOATS=yes,no]
[         bqhw, bq32, bq64[b]:  BYTE_QUOTA_MODEL=BQM_*]],
[[ac_save_IFS=$IFS
IFS=,
for moo_kwd in ,x $enableval ; do
  IFS=$ac_save_IFS]
  AS_CASE([$moo_kwd],[[
    ,x]],    [[continue]],                              [[
    bqhw]],  [[moo_d=BYTE_QUOTA_MODEL; moo_v=BQM_HW]],  [[
    bq32]],  [[moo_d=BYTE_QUOTA_MODEL; moo_v=BQM_32]],  [[
    bq64]],  [[moo_d=BYTE_QUOTA_MODEL; moo_v=BQM_64]],  [[
    bq64b]], [[moo_d=BYTE_QUOTA_MODEL; moo_v=BQM_64B]], [[
    i64]],   [[moo_d=INT_TYPE_BITSIZE; moo_v=64]],      [[
    i32]],   [[moo_d=INT_TYPE_BITSIZE; moo_v=32]],      [[
    i16]],   [[moo_d=INT_TYPE_BITSIZE; moo_v=16]],      [[
    flt]],   [[moo_d=FLOATING_TYPE; moo_v=FT_FLOAT]],   [[
    fdbl]],  [[moo_d=FLOATING_TYPE; moo_v=FT_DOUBLE]],  [[
    flong]], [[moo_d=FLOATING_TYPE; moo_v=FT_LONG]],    [[
    fquad]], [[moo_d=FLOATING_TYPE; moo_v=FT_QUAD]],    [[
    box]],   [[moo_d=BOXED_FLOATS; moo_v=yes]],         [[
    unbox]], [[moo_d=BOXED_FLOATS; moo_v=no]],
    [AC_MSG_ERROR([unknown --enable-$1 keyword: $moo_kwd])])
  AS_VAR_SET_IF([moo_d_$moo_d],
    [AS_VAR_COPY([moo_v],[moo_d_$moo_d])
     AC_MSG_ERROR([[--enable-$1=...,$moo_kwd: $moo_d already set to $moo_v]])])
  AS_VAR_SET([moo_d_$moo_d],[[$moo_v]])
  AC_MSG_NOTICE([(--enable-$1:) $moo_d = $moo_v])[
done]])])
