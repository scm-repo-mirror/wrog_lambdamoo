# SYNOPSIS
#
#   # Declare one or more extensions
#   # (best to have this in a separate file [extensions.ac]
#   #  to be m4_included near the top of configure.ac)
#   #
#   MOO_XT_DECLARE_EXTENSIONS([
#     %%extension one
#       <subcmds>...
#     %%extension two
#       <subcmds>...
#   ])
#
#   # Define all --enable/--with arguments associated with extensions
#   # (since this sets moo_d_OPTION shell variables,
#   #  this must be before MOO_OPTION_ARG_ENABLES)
#   #
#   MOO_XT_EXTENSION_ARGS()
#
#   # Do all actual configuration of chosen extensions, e.g.,
#   # directory/include/library checks, setting of makefile and
#   # preprocessor variables, etc...  (should be near the end, after
#   # all of the mandatory requirements are established, probably the
#   # last thing before AC_OUTPUT)
#   #
#   MOO_XT_CONFIGURE_EXTENSIONS()
#
# DESCRIPTION
#
#   This defines and implements the language for
#   specifying extensions in the LambdaMOO server build system.
#
# AUTHOR/COPYRIGHT/LICENSE
#
#   Copyright (C) 2023, 2024  Roger F. Crew
#
#   This program is free software; you can redistribute it and/or
#   modify it under the terms of the GNU General Public License
#   as published by the Free Software Foundation; either version 2
#   of the License, or (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.


#-----------------------------------------------------
# world-visible definitions
#
AC_DEFUN([MOO_XT_DECLARE_EXTENSIONS],
  [m4_if([$9],[ end of extension declarations ],[],
    [m4_fatal([bad trailer for $0 ($9)])])dnl
_moo_xt_set_global_state([1], [2])dnl
AX_LP_PARSE_SCRIPT([XTL_MOO],
     [[_MOO_XT_EXTENSION_ARGS],[_MOO_XT_CONFIGURE_EXTENSIONS],[MOO_XT_SGRP]],
     [$1])])

AC_DEFUN([MOO_XT_EXTENSION_ARGS],
  [_moo_xt_set_global_state([2], [0])dnl
# ------------- extension arguments
_$0()
#
# ------------- end of extension arguments
])

AC_DEFUN([MOO_XT_CONFIGURE_EXTENSIONS],
  [_moo_xt_set_global_state([2], [0])dnl
# ------------- extension configurations
m4_set_map([_moo_xtl_substed_makevars],[AC_SUBST])dnl
_$0()
_MOO_XT_CONFIGURE_EPILOG()
#
# ------------- end of extension configurations
])

# These get m4_append()ed as we process the scripts:
m4_define([_MOO_XT_EXTENSION_ARGS])
m4_define([_MOO_XT_CONFIGURE_EXTENSIONS])

# put ALL_XT_CSRCS/HDRS once we have all of them
m4_define([_MOO_XT_CONFIGURE_EPILOG],
[m4_map_args_sep(
  [ax_lp_beta([&],[
[ALL_XT_&1=']][m4_set_map_sep([MOO_XT_SGRP_&1],[],[],[ ])[']],], [)],
  [], [CSRCS], [HDRS])])


# A vaguely useful debugging tool (output of this will inevitably
# be better-formatted than what ends up in ./configure)
#
m4_define([MOO_XT_DUMP_EVERYTHING],
[m4_errprint([-------
_MOO_XT_EXTENSION_ARGS:
-------
]m4_defn([_MOO_XT_EXTENSION_ARGS])[
-------
_MOO_XT_CONFIGURE_EXTENSIONS:
-------
]m4_defn([_MOO_XT_CONFIGURE_EXTENSIONS])
)])


#--------------
# global_state

# We need to ensure that once either of MOO_XT_EXTENSION_ARGS or
# MOO_XT_CONFIGURE_EXTENSIONS get invoked, no further scripts can be
# parsed.  So, there are three states:
#     [0]  - nothing seen yet
#     [1]  - MOO_XT_DECLARE_EXTENSIONS seen, but nothing else
#     [2]  - after MOO_XT_EXTENSION_ARGS or MOO_XT_CONFIGURE_EXTENSIONS
#
m4_define([_moo_xt_global_state], [0])

# _moo_xt_set_global_state([NEW-STATE],[NOT-ALLOWED])
#
m4_define([_moo_xt_set_global_state],
  [m4_if([_moo_xt_global_state], [$2],
     [AC_MSG_ERROR(m4_case([$2],
       [0], [[[No extensions defined.]]],
       [1], [[[*** THIS SHOULD NOT HAPPEN, report me ***]]],
       [2], [[[Too late for further extension declarations.]]]))])dnl
m4_define([_moo_xt_global_state], [$1])])


#-------------------------------
# makevars

# each optional source for an extension
# belongs to a source group
m4_define([_moo_xtl_source_groups], [[CSRCS], [HDRS]])

# _moo_xtl_direct_makevars
#   makevars where <var>=<value> appends <value> directly
#   (for all others, append <var>=<value> to XT_MAKEVARS)
#
m4_set_add_all([_moo_xtl_direct_makevars],
  [CPPFLAGS], [XT_LOBJS])
  # +XT_<sourcegroup>  for all sourcegroups

# _moo_xtl_reserved_makevars
#   makevars for which <var>=<value> is not allowed
#
m4_set_add_all([_moo_xtl_reserved_makevars],
  [XT_DIRS], [XT_MAKEVARS], [XT_RULES])
  # +ALL_XT_<sourcegroup>  for all sourcegroups

# _moo_xtl_makevar_source_group_<makevar>
#    source group corresponding to <makevar> (if defined)
#
m4_map_args_sep(
  [ax_lp_beta([&], [m4_do(
       m4_define([_moo_xtl_makevar_source_group_XT_&1],[&1]),
       m4_set_add([_moo_xtl_direct_makevars], [XT_&1]),
       m4_set_add([_moo_xtl_reserved_makevars], [ALL_XT_&1]))],
     ], [)], [],
  _moo_xtl_source_groups)

# _moo_xtl_append_source_group(<MAKEVAR>,<VALUE>)
#   if <MAKEVAR> is XT_<sourcegroup>,
#   split <VALUE> into filenames and add them to that group
#
m4_define([_moo_xtl_append_source_group],
  [m4_ifdef([_moo_xtl_makevar_source_group_$2],
    [m4_set_add_all(
      ax_lp_get([$1],[g_srcgrp])[_]m4_defn([_moo_xtl_makevar_source_group_$2]),
      m4_unquote(m4_split([$3])))])])

# _moo_xtl_substed_makevars
#    all makevars that have substitutions due to extensions
#
m4_set_add_all([_moo_xtl_substed_makevars]dnl
[]m4_set_listc([_moo_xtl_direct_makevars])dnl
[]m4_set_listc([_moo_xtl_reserved_makevars]))

# moo_xtl_add_makevar(<CTX>,<VAR>,<VALUE>)
#    perform assignment for '=', '%dirvar', and '%make' subcmds
#
m4_define([moo_xtl_add_makevar],
  [m4_set_contains([_moo_xtl_reserved_makevars], [$2],
    [ax_lp_fatal([$1],['$2' cannot be assigned here])],
    [m4_set_contains([_moo_xtl_direct_makevars], [$2],
      [_$0($@)_moo_xtl_append_source_group($@)],
      [_$0([$1], [XT_MAKEVARS], [$2 = $3])])])])

# _moo_xtl_makevar_sep_<VAR>
#    -> separator to use when adding a value to <VAR>
#
m4_define([_moo_xtl_makevar_sep], ax_lp_NTSC(
  [m4_ifdef([_moo_xtl_makevar_sep_$1],
     [m4_defn([_moo_xtl_makevar_sep_$1])], [S])]))
m4_define([_moo_xtl_makevar_sep_XT_RULES],    ax_lp_NTSC([N]))
m4_define([_moo_xtl_makevar_sep_XT_MAKEVARS], ax_lp_NTSC([N]))

# _moo_xtl_add_makevar(<CTX>,<VAR>,<VALUE>)
#    append [sep]?[value] to [var]
#
m4_define([_moo_xtl_add_makevar],
  [ax_lp_hash_append([$1], [makevars], [$2],
     [$3], _moo_xtl_makevar_sep([$2]))])

# _moo_xtl_put_makevars(<CTX>,<INDENT>)
#   -> shell code to actually set all of the makevars
#      affected at this level
#
m4_define([_moo_xtl_put_makevars],
  [ax_lp_hash_map_keys_sep([$1], [makevars],
    [m4_pushdef([moo_v],],
    [)
m4_format([[%*s]],[$2])dnl
ax_lp_beta([&],m4_if(m4_defn([moo_v]),[XT_MAKEVARS],
                     [[[&1="$&1${&1+&2}&3"]]],
		     [[[&1=$&1${&1+'&2'}'&3']]]),
       m4_defn([moo_v]),
       _moo_xtl_makevar_sep(m4_defn([moo_v])),
       ax_lp_hash_get([$1], [makevars],
                      m4_defn([moo_v])))dnl
m4_popdef([moo_v])])])

#-------------------------------
# cdefines

#   mode 0:  %cdefine name value?(default=yes)
#     #define [name] [value]/1 if this extension is active
#     %option/%lib optional second arg is a 2nd #define
#       that should be set if that option/lib is selected
#
#   mode 1:  %cdefine nameformat_%s
#     #define nameformat_NAME (yes/1) if option/lib NAME is selected
#     %option/%lib second arg substitutes for NAME
#
#   mode 2:  %cdefine name valueformat_%s
#     #define [name] is enumeration of valueformat_NAME values
#     %option/%lib second arg substitutes for NAME
#     for %%extension, value is bit-or(|) of selected options
#     for %require, value is that of selected lib

# _moo_xtl_cdef_setup(<CTX>,<NAME_ARG>,<VALUE_ARG>)
#    process a %cdefine
m4_define([_moo_xtl_cdef_setup], [m4_do(
  m4_ifval(ax_lp_get([$1], [cdef_sym]),
    [ax_lp_fatal([$1],['%cdefine' again? ])]),

  ax_lp_set_empty([$1], [all_kwds], [],
    [ax_lp_fatal([$1], m4_joinall([ ],
      ['%cdefine' must come before any],
      m4_if(ax_lp_parent_cmd([$1]), [%%extension],
        [['%option']], [['%lib']]))))]),

  m4_ifval([$2],
    [m4_if(m4_bregexp([$2],[%s]),[-1],
      [ax_lp_put([$1], [cdef_sym], [$2])],
      [m4_do(
         ax_lp_put([$1], [cdef_sym], m4_dquote([$2])),
         ax_lp_put([$1], [cdef_mode], [1]))])],
    [ax_lp_fatal([$1],['%cdefine' name required])]),

  m4_ifval([$3],
    [m4_if(ax_lp_get([$1], [cdef_mode]),[1],
      [ax_lp_fatal([$1],['%cdefine name%s value' not allowed])],
      [m4_if(m4_bregexp([$3],[%s]),[-1],
        [ax_lp_put([$1], [cdef_val], [$3])],
        [m4_do(
           ax_lp_put([$1], [cdef_val], m4_dquote([$3])),
           ax_lp_put([$1], [cdef_mode], [2]))])])]),

  m4_if(ax_lp_get([$1], [cdef_mode]),[0],
    [ax_lp_set_add([$1], [all_cdefs], [$2])]))])

# when encountering   %option/%lib <NAME> <KEYWORD>?
# (<CTX>, <NAME>, <KEYWORD>)
#   -> _moo_xtl_add_cdef2(<CTX>, <CPPSYM>, <CPPVALUE>)
m4_define([_moo_xtl_add_cdef],
  [m4_case(ax_lp_get([$1], [cdef_mode]),
    [2], [_moo_xtl_add_cdef2([$1],
              ax_lp_get([$1], [cdef_sym]),
              m4_format(ax_lp_get([$1], [cdef_val]),
                 m4_default_quoted([$3], m4_toupper([$2]))))],
    [1], [_moo_xtl_add_cdef2([$1],
              m4_format(ax_lp_get([$1], [cdef_sym]),
                        m4_default_quoted([$3],m4_toupper([$2]))))],
    [0], [m4_ifval([$3], [_moo_xtl_add_cdef2([$1], [$3])])],
    [m4_fatal([cant happen (cdef_mode = ]ax_lp_get([$1], [cdef_mode])[)])])])

m4_define([_moo_xtl_add_cdef2],[m4_do(
  ax_lp_put([$1],     [this_cdef], [$2]),
  ax_lp_set_add([$1], [all_cdefs], [$2]),
  ax_lp_put([$1],     [this_cval], [$3]))])



#=======================
# The XTL language
#=======================

AX_LP_DEFINE_LANGUAGE([XTL_MOO],[MOO_XTL_DEFINE])

#----------
# root cmd
#----------

MOO_XTL_DEFINE([],
  [:var],  [[g_args],      [$2]],
  [:var],  [[g_configure], [$3]],
  [:var],  [[g_srcgrp],    [$4]])

# purposefully screw things up (uncomment to test for underquoting)
# m4_define([extension],[detention])
# m4_define([LANGUAGE_BITWISE],[LANGUAGE_FRACKYOU])
# m4_define([identifiers],[identif4ckifiers])
# --- these do not work; autoconf internals are underquoted
# m4_define([yes],[maybe])
# m4_define([CFLAGS],[CFLAGS_CAN_BITE_ME])
# (end test)

#-------------
# %%extension
#-------------

MOO_XTL_DEFINE([%%extension],
  [:parent], [],
  [:subcmds],[[%disabled], [--enable-], [%cdefine],
              [%option], [%option_set], [%?]],
  [:vars],   [[xt_acarg], [xt_cases], [xt_disabled],
              [ew], [ew_var], [ew_name], [ew_vdesc],
              [help], [cdef_sym], [cdef_val],
              [reqs], [req2s]],
  [:var],    [[cdef_mode], [0]],
  [:var],    [[xt_name],  [$2]],
  [:sets],   [[all_kwds], [all_options], [all_cdefs]],

  [:subcmds],[[=]],
  [:hashes], [[makevars]],

  [:fnend],
[m4_append(ax_lp_get([$1], [g_args]),
  ax_lp_beta([&], [[
#
#  Arguments for extension &1
#
&2]],
	ax_lp_get([$1], [xt_name], [xt_acarg])))dnl
dnl
m4_append(ax_lp_get([$1], [g_configure]),
  ax_lp_beta([&], [[
#
#  Configure &1 extension
#
]m4_ifval([&4],[[AS_IF([[$moo_xt_do_&1]],[[&4]])]])dnl
[&2][&3]],
	ax_lp_get([$1],[xt_name],[reqs],[req2s]),
	_moo_xtl_put_makevars([$1],[2])))])


MOO_XTL_DEFINE([%disabled],
  [:fn], [ax_lp_put([$1], [xt_disabled], [1])])


MOO_XTL_DEFINE([=],
  [:fn], [moo_xtl_add_makevar([$1],[$2],[$3])])


# (--enable-|--with-) *<NAME> *(= *<DESCRIPTION>)?
#     -> (<NAME>, <DESCRIPTION>)
m4_define([_moo_xtl_args_ew],
  [[:args], ax_lp_NTSC(
   [m4_bregexp(]m4_dquote([$][2])[,
	       [\`\([^=ST]*\)[ST]*\(\|=[ST]*\(.*\)\)],
	       [[\1],[\3]])])])

MOO_XTL_DEFINE([--enable-],
  [:subcmds], [[%?], [%?-]],
  _moo_xtl_args_ew,
  [:fn],
    [_moo_xtl_ew_defns([$1], [enable], [$2], [$3])])

MOO_XTL_DEFINE([--with-],
  [:subcmds], [[%?], [%?*]],
  _moo_xtl_args_ew,
  [:fn],
    [_moo_xtl_ew_defns([$1], [with], [$2], [$3])])

m4_define([_moo_xtl_ew_defns],
  [ax_lp_put([$1], [ew], [$2])dnl
m4_ifval([$3],[],[ax_lp_fatal([$1],['--enable|with-' name expected])])dnl
ax_lp_put([$1], [ew_name], [$3])dnl
ax_lp_put([$1], [ew_vdesc], [$4])dnl
ax_lp_put([$1], [ew_var], m4_translit([[$2-$3]],[-+.],[___]))])



MOO_XTL_DEFINE([%?],[:fn], ax_lp_NTSC(
  [m4_ifval(
    ax_lp_ifdef([$1], [kwd_select],
                [m4_if(ax_lp_parent_cmd([$1],[2]), [%build],[],[1])]),
    [ax_lp_append([$1], [help],
       m4_format([[[N%22s: . . %s]]],
         ax_lp_get([$1], [kwd_select]), [$2]))],
    [m4_if(ax_lp_parent_cmd([$1]),[%%extension],
	   [ax_lp_append([$1], [help], [[NS$2]])],
	   [_moo_xtl_addhelp([$1],
	       ax_lp_get([$1], [ew]),
	       ax_lp_get([$1], [ew_vdesc]),
	       [$2])])])]))

MOO_XTL_DEFINE([%?-],[:fn],
  [_moo_xtl_addhelp([$1],
     m4_if(ax_lp_get([$1], [ew]),[enable],[[disable]],[[without]]),
     [],[$2])])

MOO_XTL_DEFINE([%?*],[:fn],
  [ax_lp_append([$1], [help], [
AS_HELP_STRING([],[$2],[28])])])

m4_define([_moo_xtl_addhelp],
  [ax_lp_append([$1], [help],
    m4_format([[%sAS_HELP_STRING([--$2-%s%s],[%s])]],
      m4_ifval(ax_lp_get([$1], [help]), m4_newline()),
      ax_lp_get([$1], [ew_name]),m4_ifval([$3],[[=$3]]),[$4]))])


# common case of arguments being whitespace-separated words
m4_define([_moo_xtl_args_split_into_words],
  [[:args],
   [m4_unquote(m4_split(]m4_dquote([$][2])[))]])


MOO_XTL_DEFINE([%cdefine],
  _moo_xtl_args_split_into_words,
  [:fn],
    [_moo_xtl_cdef_setup($@)])


MOO_XTL_DEFINE([%option],
  [:subcmds], [[%implies], [%?], [%alt]],

  _moo_xtl_args_split_into_words,
  [:sets], [[opt_implies]],
  [:var],  [[opt_name],  [$2]],
  [:var],  [[kwd_select],[$2]],

  [:fn], [m4_do(
    _moo_xtl_set_require_new([$1], [all_kwds], [$2]),
    ax_lp_set_add([$1], [all_options],[$2]))],

  [:vars], [[this_cdef], [this_cval]],
  [:fn], [_moo_xtl_add_cdef([$1],[$2],[$3])])


MOO_XTL_DEFINE([%alt],
  [:fn], [m4_do(
    _moo_xtl_set_require_new([$1], [all_kwds], [$2]),
    ax_lp_ifdef([$1], [kwd_xselect],
      [ax_lp_put([$1], [kwd_xselect],
        [x$2|]ax_lp_get([$1], [kwd_xselect]))]),
    ax_lp_put([$1], [kwd_select],
      [$2|]ax_lp_get([$1], [kwd_select])))])


MOO_XTL_DEFINE([%implies],
  [:fn], [m4_do(
    _moo_xtl_set_require_prev([$1], [all_kwds], [$2]),
    ax_lp_set_add([$1], [opt_implies], [$2]))])


MOO_XTL_DEFINE([%option_set],
  [:args], ax_lp_NTSC(
    [m4_if(m4_bregexp([$2],[^[^TS]+[TS]*=]),[-1],
      [ax_lp_fatal([$1],[= expected])],
      [m4_bpatsubst([[$2]],
        [^.\([^TS]+\)[TS]*=[TS]*\(.*\).$],
        [[\1],m4_do(m4_split([\2],[,[TS]*]))])])]),

  [:sets], [[os_mems]],
  [:var],  [[os_name], [$2]],

  [:fn], [m4_do(
    m4_map_args_sep(
      [_moo_xtl_set_require_new([$1], [all_kwds],], [)], [],
      m4_do(m4_split([$2],[|]))),
    m4_map_args_sep(
      [_moo_xtl_set_require_prev([$1], [all_kwds],], [)], [],
      m4_shift2($@)),
    ax_lp_set_add_all([$1], [os_mems], m4_shift2($@)))],

  [:fnend], [m4_do(
     ax_lp_append([$1], [help],
       m4_format(ax_lp_NTSC([[[N%22s: . . %s]]]),
         ax_lp_get([$1], [os_name]),
         ax_lp_set_map_sep([$1], [os_mems],[],[],[[+]]))),
     ax_lp_append([$1], [xt_cases],
       _moo_xtl_xtset_cases([$1],
          ax_lp_get([$1], [os_name]), [os_mems])))])

m4_define([_moo_xtl_xtset_cases],
  [ax_lp_beta([&], [[,[[
      $2]], [[
        moo_ll="&1&2"
        continue]]]],
                m4_if([$2],[yes],[[__done__]],[[$moo_ll]]),
                ax_lp_set_map_sep([$1], [$3], [[,]]))])


MOO_XTL_DEFINE([%require],
  [:parent],  [%%extension],
  [:subcmds], [[--with-], [%cdefine], [%ac_yes]],

  [:sets], [[all_kwds], [all_cdefs]],
  [:vars], [[ew_name],[ew_var],[ew_vdesc],[yescode],
            [all_libs],[cdef_sym],[cdef_val],[rq_acarg],
            [icases],[scases],[ucases],
            [help],[blds]],
  [:var],  [[cdef_mode], [0]],
  [:var],  [[rq_name],  [$2]],
  [:var],  [[ew],     [with]])


# _moo_xtl_with_arg([ctx])
#   -> AC_ARG_WITH for %require or %build
#
m4_define([_moo_xtl_with_arg],
  [ax_lp_beta([&], [[
AC_ARG_WITH([&2],
  [&3],
[AS_CASE([[$withval]],[[
   no]],[
     AS_IF([[$moo_xt_do_&1]],[
       AC_MSG_ERROR([[--without-&2 $_moo_xt_conflict]])])[
     _moo_xt_saw_no=:
     _moo_xt_conflict="conflicts with --without-&2"]],
[
     AS_IF([[$_moo_xt_saw_no]],[
       AC_MSG_ERROR([[--with-&2 $_moo_xt_conflict]])])[
     moo_xt_do_&1=:
     _moo_xt_conflict="conflicts with --with-&2"]])])]],

                 ax_lp_get([$1], [xt_name], [ew_name], [help]))])


MOO_XTL_DEFINE([%lib],
  [:parent], [%require],
  [:subcmds],[[%ac], [%alt]],
  _moo_xtl_args_split_into_words,
  [:vars],   [[code]],
  [:var],    [[lib_name],   [$2]],
  [:var],    [[kwd_select], [$2]],
  [:var],    [[kwd_xselect],[x$2]],

  [:subcmds],[[=]],
  [:hashes], [[makevars]],

  [:fn], [m4_do(
    ax_lp_append([$1], [all_libs], [$2], [[ ]]),
    _moo_xtl_set_require_new([$1], [all_kwds], [$2]))],

  [:vars], [[this_cdef], [this_cval]],
  [:fn], [_moo_xtl_add_cdef([$1],[$2],[$3])])


MOO_XTL_DEFINE([%build],
  [:parent],  [%lib],
  [:subcmds], [[--with-],[%ac]],

  [:vars],   [[ew_name],[ew_var],[ew_vdesc],[help],[code]],
  [:var],    [[ew], [with]],

  [:subcmds],[[=], [%make], [%dirvar], [%path]],
  [:vars],   [[dirvar], [path]],
  [:hashes], [[makevars]])


MOO_XTL_DEFINE([%dirvar],
  [:fn], [m4_do(
     m4_ifval(ax_lp_get([$1], [dirvar]),
       [ax_lp_fatal([$1], [second %dirvar for this %build?])]),
     m4_set_contains([_moo_xtl_substed_makevars], [$2],
       [ax_lp_fatal([$1], [$2 cannot be used as %dirvar])]),
     ax_lp_put([$1], [dirvar], [$2]),
     _moo_xtl_add_makevar([$1], [XT_MAKEVARS], [$2 = $moo_xtdir]),
     _moo_xtl_add_makevar([$1], [XT_DIRS], [$($2)]))])

MOO_XTL_DEFINE([%path],
  [:fn], [m4_do(
    m4_ifval(ax_lp_get([$1], [path]),
       [ax_lp_fatal([$1],[second %path in this %build?])]),
    m4_ifval([$2],
       [ax_lp_put([$1], [path], [$2])],
       [ax_lp_fatal([$1],[%path directory expected])]))])

MOO_XTL_DEFINE([%make],
  [:args],
    [_moo_xtl_trimmake([$2])],
  [:fn],
    [_moo_xtl_add_makevar([$1],[XT_RULES],[$2])])

m4_define([_moo_xtl_trimmake], ax_lp_NTSC(
 [m4_bpatsubsts([[$1]],
  [\`\(..\)\([ST]*N\)+],[\1],
  [\([^N]\)\([ST]*N\)*\(..\)\'],[\1N\3],
  [^\(T.*\)N\(..\)\'],[\1NN\2])]))


MOO_XTL_DEFINE([%ac],
  [:fn],
    [ax_lp_put([$1], [code], [$2])])

MOO_XTL_DEFINE([%ac_yes],
  [:fn],
    [ax_lp_put([$1], [yescode], [$2])])


m4_define([_moo_xtl_set_require_new],
  [ax_lp_set_add([$1], [$2], [$3], [],
    [ax_lp_fatal([$1],[keyword '$3' already defined])])])

m4_define([_moo_xtl_set_require_prev],
  [ax_lp_set_contains([$1], [$2], [$3], [],
    [ax_lp_fatal([$1],[unknown keyword: '$3'])])])


MOO_XTL_DEFINE([%option],
  [:fnend],
    [ax_lp_append([$1], [xt_cases],
      m4_format(ax_lp_NTSC([[,[[N%*s%s]], [%s]]]),
        [6],[],
        ax_lp_get([$1], [kwd_select]),
        m4_do(m4_dquote_elt(
          m4_ifval(ax_lp_get([$1], [this_cdef]),
            [ax_lp_beta([&],
              m4_if(ax_lp_get([$1], [cdef_mode]),[2],
[[[
        AS_CASE([[$moo_v'|']],[[
          *"|&2|"*]],[[
            continue]],[[
            moo_v="$moo_v|&2"]])]]],
[[[[
        moo_d=&1]
        AS_VAR_SET_IF([moo_d_$moo_d],[[continue]],[[moo_v=&2]])]]]),

                ax_lp_get([$1], [this_cdef]),
                m4_default_quoted(ax_lp_get([$1], [this_cval]),[yes]))]),

          ax_lp_set_empty([$1], [opt_implies],
            [], [m4_format(
[[[
        moo_ll="$moo_ll%s"]]],
                   ax_lp_set_map_sep([$1], [opt_implies],[[,]]))]),

          m4_ifval(ax_lp_get([$1], [this_cdef]),
            [],
[[[
        continue]]])))))])


MOO_XTL_DEFINE([%build],
  [:fnend],
  [m4_ifval(ax_lp_get([$1], [dirvar]),[],
    [ax_lp_fatal2([$1],[%dirvar required],[... by %build])])dnl
dnl
ax_lp_beta([&],
  [m4_ifval([&1],
    [ax_lp_append([$1], [rq_acarg], _moo_xtl_with_arg([$1])dnl
m4_ifval([&3],[],[[
AS_CASE([[$&2]],[[
  yes]], [
    AC_MSG_ERROR([[--with-&1 requires a directory (%path not set)]])])]]))],
    [m4_ifval([&3],[],
      [ax_lp_fatal2([$1],[one of --with- or %path required],[... by %build])])])],

           ax_lp_get([$1],[ew_name],[ew_var],[path]))dnl
dnl
ax_lp_append([$1], [blds],
          ax_lp_beta([&], [[
  AS_IF([[test "x$moo_xt_rquse_&1" = x]],]dnl
m4_ifval([&2],[[[
    AS_CASE([[x$&2]],[[
      x|xno]],[],[&5][&6])]]],
  [m4_ifval([&4],[[[
    AS_CASE([[x$&4]],[[
      xno]],[],[[
      x|xyes|&3]],[&6])]]],
    [[&6]])])[)]],

           ax_lp_get([$1],[rq_name],[ew_var],[kwd_xselect]),
	   ax_lp_get_prior([$1],[ew_var]),

	   ax_lp_beta([&],[m4_ifval([&1],[m4_ifval([&4],[[
      AS_CASE([[x$&1]],[[
        x|xyes|&7]],[],
        [AC_MSG_ERROR([[--&6-&5=DIR vs. --&3-&2=$&1]])])]])])],

	     ax_lp_get_prior([$1],[ew_var],[ew_name],[ew]),
	     ax_lp_get([$1],      [ew_var],[ew_name],[ew],
				  [kwd_xselect])),

	   ax_lp_beta([&],[[[
      moo_xt_rquse_&1=&2]&5
      AS_SET_CATFILE([moo_xtdir1],[$srcdir],[$moo_xtdir0])
      AS_IF([[test -d "$moo_xtdir1"]],[],[
	AC_MSG_ERROR([[directory not found: $moo_xtdir1]])])
      AS_SET_CATFILE([moo_xtdir],['$(abs_srcdir)'],[$moo_xtdir0])[&4]]dnl
m4_ifval([&3],[m4_bpatsubst([[
      &3]],[%dir],[$moo_xtdir1])])],

             ax_lp_get([$1],[rq_name],[lib_name],[code]),
             _moo_xtl_put_makevars([$1],[6]),
	     ax_lp_beta([&],[m4_ifval([&1],[m4_ifval([&2],[[
      AS_IF([[test "x$&1" = xyes]],[[
        moo_xtdir0="&2"]],[[
        moo_xtdir0=$&1]])]],[[[
      moo_xtdir0=$&1]]])],[[[
      moo_xtdir0="&2"]]])],
               ax_lp_get([$1],[ew_var],[path])))))])

MOO_XTL_DEFINE([%lib],
   [:fnend],
   [ax_lp_append([$1], [icases], ax_lp_beta([&],
[[,[[
      &1]],  [[
        moo_xt_rqtry_&2="$moo_xt_rqtry_&2 &3"]]]],

      ax_lp_get([$1], [kwd_select]), ax_lp_get([$1], [rq_name]),
      ax_lp_get([$1], [lib_name])))dnl
ax_lp_append([$1], [scases],
  ax_lp_beta([&],
    m4_ifval(ax_lp_get([$1], [code]),
[[[,[[
      &3]],  [
        &1
        AS_IF([[$_moo_xt_found_it_]],[[
          moo_xt_rquse_&2=&3
          break]])]]]],
[[[,[[
      &3]],  [
        _moo_xt_found_it_=:
        moo_xt_rquse_&2=&3
        break]]]]),

             m4_bpatsubsts(m4_dquote(ax_lp_get([$1], [code])),
               [%%],[_moo_xt_found_it_=:],
               [%!],[_moo_lfail1]),
             ax_lp_get([$1],[rq_name],[lib_name])))dnl
dnl
ax_lp_append([$1], [ucases],
  ax_lp_beta([&], m4_format(
[[[,[[
  x&1]],  [%s&4]]]], m4_ifval(ax_lp_get([$1], [this_cdef]),[[
    AC_DEFINE([&2], [&3])]])),

             ax_lp_get([$1],[lib_name],[this_cdef]),
             m4_default_quoted(ax_lp_get([$1], [this_cval]),[1]),
             _moo_xtl_put_makevars([$1],[4])))])


MOO_XTL_DEFINE([%require],
  [:fnend],

dnl  xt.[xt_acarg] +=
dnl    AC_ARG_WITH for --with-<req> and each of
dnl      the various builds for <req>  ([rq_acarg])
dnl
[ax_lp_append([$1], [xt_acarg],
  m4_ifval(ax_lp_get([$1], [ew_name]),
    [_moo_xtl_with_arg([$1])])dnl
ax_lp_get([$1], [rq_acarg]))dnl
dnl
dnl  make [yescode] set moo_xt_rqtry_<req>
dnl    prior value being either blank, "lib1,lib2,..."
dnl      or something that sets %%.
dnl
m4_ifval(ax_lp_get([$1], [yescode]),[],
  [ax_lp_put([$1], [yescode], ["]ax_lp_get([$1], [all_libs])["])])dnl
m4_if(m4_bregexp(ax_lp_get([$1], [yescode]),[%%]), [-1],
      [ax_lp_put([$1], [yescode],
		 m4_dquote([%%=]ax_lp_get([$1], [yescode])))])dnl
ax_lp_put([$1], [yescode],
  m4_bpatsubst(m4_dquote(ax_lp_get([$1], [yescode])),
	       [%%], [moo_xt_rqtry_]ax_lp_get([$1], [rq_name])))dnl
dnl
dnl  xt.[reqs] +=
dnl    if a %build was selected, set makevars/etc for it and also
dnl      set moo_xt_rquse_<req>=corresponding lib (rq.[blds])
dnl    otherwise set moo_xt_rqtry_<req> to library search order
dnl      (using rq.[icases] and rq.[yescode])
dnl
ax_lp_append([$1], [reqs],
  ax_lp_beta([&], [[[
moo_xt_rquse_&2=]]m4_ifval([&6],[[
AS_IF([[$moo_xt_do_&1]],[&6])]])[[
moo_l=]]m4_ifval([&4],[[[$&3]]])[[
moo_xt_rqtry_&2=]
AS_IF([[test x$moo_xt_rquse_&2 = x]],[
  AS_IF([[test x$moo_l = x]],[
    AS_IF([[$moo_xt_do_&1]],[[moo_l=yes]],[[moo_l=no]])])[
  ac_save_IFS=$IFS
  IFS=,
  for moo_kwd in $moo_l ; do
    IFS=$ac_save_IFS]
    AS_CASE([[$moo_kwd]]&7,[[
      no]],  [[
        moo_xt_rqtry_&2=
        break]],[[
      yes]], [
        &8[
        break]],[
      AC_MSG_ERROR([[unknown --&5-&4 keyword: $moo_kwd]])])[
  done]])]],
             ax_lp_get([$1],[xt_name],[rq_name],
                            [ew_var],[ew_name],[ew],
                            [blds],[icases],[yescode])))dnl
dnl  xt.[req2s] +=
dnl    do the library search (using rq.[scases])
dnl    set moo_xt_rquse to library found
dnl    configure library (using rq.[ucases])
dnl
ax_lp_append([$1], [req2s],
  ax_lp_beta([&],
[[
AS_IF([[test "x$moo_xt_rqtry_&2" != x]],[[
  _moo_xt_found_it_=false
  _moo_lfail_extras=
  for moo_lib in $moo_xt_rqtry_&2 ; do
    _moo_lfail1=]
    AS_CASE([[$moo_lib]]&3,[
      AC_MSG_ERROR([[?? \$moo_xt_rqtry_&2 kwd = $moo_lib]])])
    AS_IF([[test "x$_moo_lfail1" != x]],[[
      _moo_lfail_extras="$_moo_lfail_extras
  $moo_lib: $_moo_lfail1"]])[
  done]
  AS_IF([[$_moo_xt_found_it_]],[],[
    AC_MSG_ERROR([[&5: no library found$_moo_lfail_extras]])])])
AS_CASE([[x$moo_xt_rquse_&2]],[[
  x]],[]&4,[
  AC_MSG_ERROR([[?? \$moo_xt_rquse_&2 = $moo_xt_rquse_&2]])])]],

             ax_lp_get([$1],[xt_name],[rq_name],[scases],[ucases]),
             m4_ifval(ax_lp_get([$1],[ew_name]),
               [[--with-]ax_lp_get([$1],[ew_name])],
               [m4_format([[extension %s (requires %s)]],
                  ax_lp_get([$1],[xt_name],[rq_name]))])))])

MOO_XTL_DEFINE([%%extension],
  [:fnend],
  [ax_lp_set_contains([$1], [all_kwds], [yes], [],
    [dnl
dnl
dnl fix xt_cases:
dnl if no 'yes' case is provided (%option or %option_set)
dnl fill one in that sets all of the flags
ax_lp_append([$1], [xt_cases],
        m4_if(ax_lp_get([$1], [cdef_mode]),[0],
            [[,[[
      yes]], [[
        continue]]]],
            [_moo_xtl_xtset_cases([$1], [yes], [all_options])]))])dnl
dnl
dnl fix xt_cases:
dnl provide 'no' case
ax_lp_append([$1], [xt_cases], m4_format([[,[[
      no]], [[
        moo_ll=__done__%s
        break]]]],
        m4_quote(ax_lp_set_map_sep([$1], [all_cdefs], [
        moo_d_], [=no]))))dnl
dnl
dnl build xt_acarg:
dnl
ax_lp_put([$1], [xt_acarg],
  ax_lp_beta([&],
[[[moo_xt_do_&1=false
_moo_xt_saw_no=false
_moo_xt_conflict=]]]
dnl
dnl   Either we have an --enable defined
dnl
[m4_ifval([&2],[[
AC_ARG_ENABLE([&2],
  [&4],
[AS_CASE([[$enableval]],[[
   no]],[[
     _moo_xt_saw_no=:
     _moo_xt_conflict="conflicts with --disable-&2"]],
   [[
     moo_xt_do_&1=:
     _moo_xt_conflict="conflicts with --enable-&2"]])])]],
dnl
dnl  ... or we do not.  There may still be a help header
dnl
[m4_ifval([&4],[[
MOO_PUT_HELP([ENABLE],[&4])]])])],

             ax_lp_get([$1],[xt_name],[ew_name],[ew_var],[help]))dnl
dnl
dnl   include --with args defined by %require stanzas
dnl
ax_lp_get([$1],[xt_acarg])dnl
dnl
dnl   do default cases:
dnl   non-%disabled extension needs absense of --disable/--without;
dnl   %disabled extension needs an explicit --enable/--with
dnl     which we should have seen already
dnl
ax_lp_beta([&],
  [m4_ifval([&4],[],[[
AS_IF([[$_moo_xt_saw_no]],
  [AC_MSG_NOTICE([[(%%extension &1:) disabled]])],
  [[moo_xt_do_&1=:]])]])
dnl
dnl   moo_l <- 'yes', 'no', or keyword list
dnl
[AS_IF([[$moo_xt_do_&1]],
  ]m4_ifval([&2],
    [[[AS_IF([[test "x$&3" = x]],
      [[  moo_l=yes]],[[  moo_l=$&3]])]]],
    [[[[moo_l=yes]]]])[,
  [[moo_l=no]])]],

    ax_lp_get([$1], [xt_name], [ew_name], [ew_var], [xt_disabled]))dnl
dnl
dnl   xt_cases expand keywords
dnl
ax_lp_beta([&],[[[&5
while test "$moo_l" != __done__ ; do
  ac_save_IFS=$IFS
  IFS=,
  moo_ll=__done__
  for moo_kwd in $moo_l ; do
    IFS=$ac_save_IFS]
    AS_CASE([[$moo_kwd]],[[
      __done__]],[[
        continue]]&4,[
      AC_MSG_ERROR([[unknown --enable-&2 keyword: $moo_kwd]])])&6[
  done
  moo_l=$moo_ll
done]]],

           ax_lp_get([$1],[xt_name],[ew_name],[ew_var],[xt_cases]),
           m4_if(ax_lp_get([$1], [cdef_mode]),[2],[[
moo_v=0]]),
           m4_if(ax_lp_get([$1], [cdef_mode]),[2],[],
              [ax_lp_beta([&],[[
    AS_VAR_SET([moo_d_$moo_d],[[$moo_v]])
    AC_MSG_NOTICE(]m4_ifval([&2],[[[[(--enable-&2:)]]]],[[[[(%%extension &1:)]]]])[[[ $moo_d = $moo_v]])]],

                          ax_lp_get([$1],[xt_name],[ew_name]))]))dnl
dnl
dnl  for cdefine modes 0 and 2,
dnl  we still need to set the global csymbol
dnl
ax_lp_beta([&],[m4_ifval([&2],[[
AS_IF([[$moo_xt_do_&1]],[&2])]])],
        ax_lp_get([$1], [xt_name]),
        ax_lp_beta([&],

          m4_case(ax_lp_get([$1], [cdef_mode]),
            [0],[m4_ifval(ax_lp_get([$1], [cdef_sym]), [[[
  AS_VAR_SET([moo_d_&4],[[&5]])
  AC_MSG_NOTICE([[(&6:) &4 = &5]])]]])],
            [1], [],
            [2], [[[[
  moo_v="($moo_v)"]
  AS_VAR_SET([moo_d_&4],[[$moo_v]])
  AC_MSG_NOTICE([[(&6:) %s = $moo_v]])]]]),

          ax_lp_get([$1],[xt_name],[ew_name],[ew_var],[cdef_sym]),
          m4_default_quoted(ax_lp_get([$1], [cdef_val]),[yes]),
	  ax_lp_beta([&],
	    [m4_ifval([&2],[[--enable-&2]],[[%%extension &1]])],
	    ax_lp_get([$1],[xt_name],[ew_name])))))])dnl
dnl
dnl m4_errprint(m4_defn(_ax_lp_lang_prefix([XTL_MOO])[|%%extension|:fnend]))
