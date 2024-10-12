> [!WARNING]
>
> You are viewing a **__work-in-progress__** branch that is **constantly
> being rebased** and will likely be **eventually deleted**.
> **__Fork at your own risk__**.  The following text is also undergoing
> editing, i.e., _not everything mentioned below is strictly true_
> yet, as this is not yet any kind of release.

# LambdaMOO Server

This is the source for the latest version of the LambdaMOO server.

Veteran users with existing MOO databases will, at this point, want to
consult [the ChangeLog](./ChangeLog.txt).

However, there also exist settings by which this server can be
compiled for a "compatibility mode" to run pre-existing databases
intended for 1.8.4 and earlier servers without modification, which
will at least keep you on the air while you assess which 1.9 features
you want to enable and what corresponding DB changes will be needed.
See [Legacy database support](#user-content-legacy-database-support) below.

## Getting Started

For those of you starting fresh, what to do will depend on how you got
here.  There are a number of posibilities:

### Building the LambdaMOO server from a distribution

This is arguably the simplest option for those less familiar with `git`
and the autotools.

Here, we assume you have downloaded a distribution tarball — a file of
the form `LambdaMOO-1.9.nn-dist.tar.gz` — from somewhere, did the
usual `tar xzf` to unpack it, `cd`ed into the directory you created,
and are now reading this file.

The process from here on is:

```
	./configure
	make
	make test
```

The `./configure` script will complain about missing pre-requisites.
Various situations are listed below.

### VPATH builds

To build in a different directory from where the sources live (useful
to simultaneously create versions with different options set), you
should instead do

```
	cd BUILD
	PATH/TO/SRC/configure --srcdir=PATH/TO/SRC
	make
	make test
```

where `BUILD` is a fresh directory and `PATH/TO/SRC` is whatever path
gets you from there back to the sources.  (E.g., you could build in a
subdirectory of the source directory as follows:

```
	mkdir b
	cd b
	../configure --srcdir=..
	make
	make test
```

).  Note that VPATH builds require the source directory to be
pristine.  So, if you have previously done any building there, you
will be needing to do at least a `make distclean` before any VPATH
builds elsewhere will be allowed.

### Building the LambdaMOO server from the git repository

This process is more involved:

	git clone https://github.com/wrog/lambdamoo SRCDIR
	cd SRCDIR
	autoconf
	./configure
	make
	make test

## Notes about prequisites that you might need

* `autoconf` is from the GNU Autotools suite.  Try the latest
   version first.  At the time of this writing, our package is known
   to work with autoconf versions in the range 2.69-2.72.

   Also __never__ run `autoreconf`.  We are not using the full suite.
   In particular, we are using neither `automake` nor `autoheader`,
   which will both get very confused.

* `make`, preferably GNU make.

* `gperf` version 3.1 or later

* A `yacc`-compatible parser generator: Any of `yacc`, `bison`, or
  `byacc` will do.  (We do not use `lex`.)

* The `iconv` library is needed to support `encode_chars()` and
  `decode_chars()` which are now available even in the non-Unicode
  server.

  The library itself may already be installed (it's quite popular)
  but you will also need the`-dev` package (typically a separate thing
  because most people don't compile stuff and so never need it) to get
  the `#include` headers needed to compile with.

  ... and this will be the case for __all__ of the libraries listed here.

* Unicode support requires a library to provide character data.
  The GNU project's `libunistring` is recommended and is the default.
  ICU's `libicuuc` is also supported.  `./configure` will, by default,
  find whichever of these is available, but, again, you may still need
  to install a `-dev` package to make something available.  If both
  are available, you can use `--with-uclib=gnu` or `--with-uclib=icu`
  to force a particular choice.

* the Unicode server also requires `pcre`, the Perl Compatible Regular
  Expression library to implement `match()` properly for strings
  containing non-ASCII codepoints.

  And here we mean the old version, PCRE1, not the newer and fancier
  PCRE2.  Confusingly, in Debian and Ubuntu, the package to install
  for this is actually labeled `libpcre3-dev`, I have no idea why.
  MacOS homebrew, FreeBSD, and Fedora all have perfectly reasonable
  `pcre` packages that do the right thing.

* The XML extension requires an xml library.  Currently, this has
  to be `expat` (and again you will need the `-dev` package with
  the headers).

If Unicode prequisites are not available you can still `./configure
--disable-unicode` to create a more traditional ASCII-only server.


# Using ./configure to set options

## General principles

Once you have satisfied the prequisites, `./configure` will reach the
end of its run and you will see

```
	config.status: creating options.h

```

Which means you now have an [`options.h`](./options.h) file, which
lists all of the individual settings with the fully up-to-date and
gory details of what each setting actually does __and__ _how each
option is currently set_.

> [!NOTE]
>
> __To MOO veterans__:  Yes, as of version 1.9, `options.h` is a
> _generated_ file and is now _read-only_, Which may seem weird for a
> file that was originally meant to be edited, but ... keep reading.

The best and easiest way to change option settings is by rerunning
`./configure`.

(A few of the newer options, notably `UNICODE_STRINGS`, in fact
_depend_ on ./configure to seek out necessary optional libraries and
you will likely see compiler errors *unless* you set them this way.)

Also, if you give `./configure` a `-C` flag, it will run _really,
really fast_ because it will be remembering the results of tests it
ran in the previous rounds and not having to re-do them.

You can, in fact, rerun `./configure` as many times as you like — all
it ever does is keep rewriting the same 4 or 5 files (`Makefile`,
`config.h`, `options.h`, and a few others).  So you can use it
repeatedly to try out its various arguments to see what they do to
`options.h`.

Once you get a configuration you like, you should, if you want to be
_completely_ rigorous, do one last `./configure` run with
your preferred arguments but _without_ the `-C` in order to make it
start from scratch and be sure it's doing its tests in the right order
(admittedly, I have never seen this make any difference). ...  and
_then_ you run `make`.

## arguments for ./configure

That all said, let's now look at the actual arguments available.
Either of

```
    ./configure --help=short
    ./configure -hs
```

will list them all, or at least all of the arguments that are specific
to the LambdaMOO server build process.

> [!NOTE]
>
> You actually need not bother looking at the *longer* `./configure
> -h` or `./configure -hr` help messages, since there has been, as
> yet, **zero** effort put into getting any of the ``make install``
> options listed there — which are mainly about getting
> general purpose libraries and applications installed into the
> correct system directories — to actually work, it not yet actually
> being clear what ``make install`` should even be doing given the
> wide variety of server setups that people have.  For now, as far as
> we are concerned, the build process is complete once a new `moo` executable
> exists in your source directory.

There are two classes of command-line arguments for `./configure`

* The **low-level** `--enable-def-NAME` arguments each correspond to a
  single #define-able `NAME` in `options.h`.  These arguments, in combination,
  make it possible to _completely determine_ the contents of that
  file, if you want.

  For example:

  ```
   ./configure --enable-def-LOG_COMMANDS            \
               --enable-def-DEFAULT_FG_TICKS=75000  \
               --disable-def-INPUT_APPLY_BACKSPACE
  ```

  causes the following lines to appear in `options.h`

  ```
    #define    LOG_COMMANDS          1
    #define    DEFAULT_FG_TICKS      75000
    /* #undef  INPUT_APPLY_BACKSPACE       */
  ```

  thence ultimately producing a server that will be logging commands,
  setting a default limit of 75000 ticks on every foreground task, and
  ignoring backspaces on non-binary connections.

  Note that per the general autoconf framework for how `./configure`
  arguments work,
  + `--disable-OPTION` is a synonym for `--enable-OPTION=no`, while
  + `--enable-OPTION` with no value is a   synonym for `--enable-OPTION=yes`,
     which, in turn, translates to a value of `1`
	 by the time it gets to being inserted into a `.h` file
     (so that you don't have to worry about the whether the C code uses
     `#ifdef` or `#if`)

* The **high-level** option packages, each of which manages a
  collection of options, allow you to set _all_ of the options in the
  collection with a single argument, using some combination of
  keywords.

  + `--enable-net`
    manages all of networking options (`NETWORK_PROTOCOL`,
    `NETWORK_STYLE`, `MPLEX_STYLE`, `DEFAULT_CONNECT_FILE`,
    `DEFAULT_PORT`, and `OUTBOUND_NETWORK`),
	thence allowing you to do, e.g.,

    ```
       ./configure --enable-net=tcp,8888,out
    ```

    which is equivalent to

    ```
       ./configure --enable-def-NETWORK_PROTOCOL=NP_TCP \
	               --enable-def-DEFAULT_PORT=8888       \
	               --enable-def-OUTBOUND_NETWORK=OB_ON  \
    ```

	to get a server with TCP networking, default listener on port
    8888, and `open_network_connection()` enabled by default.


  + `--enable-sz`
    manages all of the datatype options (`INT_TYPE_BITSIZE`,
	`FLOATING_TYPE`, `BOXED_FLOATS`) and `BYTE_QUOTA_MODEL`,
	thence allowing you to do, e.g.,

    ```
       ./configure --enable-sz=i32,fquad,box,bqhw
    ```

    which is equivalent to

    ```
       ./configure --enable-def-INT_TYPE_BITSIZE=32     \
	               --enable-def-FLOATING_TYPE=FT_QUAD   \
	               --enable-def-BOXED_FLOATS            \
	               --enable-def-BYTE_QUOTA_MODEL=BQM_HW
    ```

	to get a server with 32 bit integers and boxed quad floats (a
    strange combination, perhaps) using the hardware byte quota
    model for `object_bytes()` and `value_bytes()`.

    And there are option packages for most of the extensions, as described below

For those of you with legacy (LambdaCore, JHCore, etc.) databases,
there are more examples [further down](#user-content-legacy-database-support) specifically intended for
your situation.

Note that the ordering of `./configure` arguments does not matter
since (1) the high-level packages affect disjoint sets of options, and
(2) the low-level `--enable-def-` arguments will take precedence
whenever they occur.  This way, if there's some high-level setting
that does most of what you want, you can include the additional
`--enable-def` arguments to fix the settings it got "wrong".  You
_should_, however, try to do as much as you can with just the
high-level settings since they'll do a bit more sanity-checking than
the low-level settings can..

## saving your ./configure arguments

If you forgot what settings you used on your last run of `./configure`

```
   ./config.status --config
```

will repeat them back to you.  Once you have a configuration you like
you should then save the output of this command somewhere, in, say,
a shell script to run the next time you do a `git pull` or otherwise
upgrade your server sources.

## verifying your option settings

If, in a successfully compiled server, you need to verify that a
particular option setting is what you think it is, or you want to find
out how a particular `OPTION_DEFAULT` value was resolved, you can invoke
`server_version("options")` from MOO code to get a dump of all of the
compiled-in options or `server_version("options/NAME")` to view a
particular option.

Here's a simple way to do this from a shell prompt using the
"emergency wizard mode",


```
    printf "%s\n" ';server_version("options/MPLEX_STYLE")'  \
      | ./moo -e Minimal.db /dev/null 2>/dev/null
```

if, say, you were insanely curious what setting was ultimately chosen
for `MPLEX_STYLE`, now you know.

## how **NOT** to do options.h or config.h settings

As a matter of general principle, if you ever find yourself trying to
use a `-D NAME` or `-U NAME` cc argument or in a `$(CFLAGS)` or
`$(CPPFLAGS)` specification in `Makefile`(`.in`) in order to affect a
`NAME` intended to be #defined in either options.h or config.h,...

... just don't.  I can pretty much promise it won't end well.

# Legacy database support

Version 1.9, in its default installation introduces significant
changes that are likely to have consequences for existing dbs:

- The new default integer datatype is 64 bits wide, which means
  integer arithmetic wraps differently, which matters, e.g., for
  LambdaCore's `$seq_utils`, anything that uses it (e.g., `@mail`), or
  anything else that relies on `$maxint` being a certain value.

- Changes to structure layouts/sizes (the inevitable result of
  compiling on a 64-bit platform, given that all previous compilations
  of stock 1.8.4- would have to have been on a 32-bit platform due to
  the previously obsolete `configure.in`) would normally be
  invisible except in that they change the values returned by
  `object_bytes()` and `value_bytes()`, which matter, if, e.g., you
  use LambdaCore's byte-quota system.

- The expansion of the MOO character set, used for non-binary
  connections, string constants, and all object/verb/property names,
  to include nearly all legal Unicode codepoints, which for db files
  dumped from a stock 1.8.4- server should *not* actually matter
  (since ASCII is a subset of UTF-8, all prior string data and
  verbcode should be preserved).  However if your database previously
  contained and relies on strings with non-ASCII bytes (which can be
  introduced to db files via direct editing) those will get
  interpreted differently and potentially cause trouble.  Also,
  verbcode that assumes that all string chars will be in the
  ASCII range may cause trouble.

Databases produced by pre-1.9 servers are likely to need updates in
order to function correctly on a 1.9+ server compiled with the new
default settings.  The full details are in [the ChangeLog](./ChangeLog.txt).

However, you can instead compile the server so that pre-1.9 behaviors
are mostly preserved and thus have your database continue to function as
before (at least, for a while.  You will most likely want to switch to
64-bit integers sometime before 2038, which is coming sooner than you
think.)  The next sections describe how to do this.

## Configuring a "stock-LambdaMOO-1.8.4 compatibility mode" server

To be sure, there are no "compatibility modes" _per se_, i.e., no
single argument does everything, and how much you will actually *need*
to do ultimately depends on what is in your database that you care
about.  However, the following configuration

```
	./configure --disable-unicode --enable-sz=i32,bq32
```

which creates an ASCII-only server where the INT type is 32 bits wide
and the byte quota functions use the fixed 32-bit abstract memory
model, is recommended for legacy databases running on a stock
LambdaMOO-1.8.4 server, as best preserving the behaviors of that
server, and should allow you to continue running a LambdaCore-derived
or JHCore-derived MOO database without modification.

Here, by "stock", we mean a server compiled from either the 2010
sourceforge repository head or `github.com/wrog/lambdamoo` (tag
"1.8.4", commit `232293922083623e45a11b3aff2575104ad6081a`)—these
sources both being essentially identical to what has
been running at LambdaMOO for the past 14 years—with no
modifications other than changing the `options.h` settings available
in that version.

Note that `--disable-unicode` and `--enable-sz` are entirely
orthogonal to (and may thus be safely combined with) any of the
`--enable-net` settings or any `--enable-def-(CPPNAME)` for
`options.h` settings previously available in 1.8.4 (or earlier).

You may also omit `bq32`, which governs `object_bytes()` and
`value_bytes()`, if you are **not** using the LambdaCore/JHCore
byte-quota system or otherwise relying on those functions to return
the same values as before.


## Configuring a "Codepoint-1.8.3 compatibility mode" server

The Unicode implementation for this server was derived from the final
Codepoint "unicode" branch.  However there are differences between the 1.9
defaults and what existing databases that run on Codepoint-derived
servers will be expecting.  The following configuration

```
	./configure --enable-unicode=all --enable-sz=bq64b
```

which creates a Unicode server with all of the subfeatures (`ids` and
`numbers`) enabled, the INT type is 64 bits wide, and the byte quota
functions use the fixed 64-bit abstract memory model with boxed
floats, is recommended as best preserving the behaviors of the stock
Codepoint-1.8.3 server, here meaning a server compiled unmodified
(except for possible `options.h` settings) from the final Codepoint
1.8.3 "unicode" branch (commit `51761cdc98176f68a955b76a056ae364b2092a6e`).

Additionally,

* for XML support matching the final Codepoint "unicode-xml" branch,
  you will need to add `--enable-xml`.

* For WAIF support matching the final Codepoint "unicode-waif" branch
  you will need to add `--enable-waifs=core`, though if you want the
  `WAIF_DICT` patch as well (i.e., support for array syntax and
  calling of array element get/set methods), then you need
  `--enable-waifs` or (equivalently) `--enable-waifs=all` instead.

* And, as you might expect, adding *both* of the previous arguments
  gives you a server mostly equivalent to Codepoint's
  "unicode-waif-xml" branch.

* Finally, if you want to enable support for the bitwise-operations
  syntax, the necessary argument is `--enable-def-BITWISE_OPERATORS`

All of the above arguments are orthogonal to — and thus may be safely
combined with — any of the `--enable-net` settings or any
`--enable-def-(CPPNAME)` for `options.h` settings previously available
in Codepoint 1.8.3 (or earlier).

You may also omit `--enable-sz=bq64b`, which governs `object_bytes()`
and `value_bytes()`, if you are **not** using the LambdaCore/JHCore
byte-quota system and otherwise **not** relying on those functions to
return the same values as before.  (Note that the 1.9 default for the
byte quota memory model is actually `bq64` or, equivalently
`--enable-def-BYTE_QUOTA_MODEL=BQM_64`, which counts the byte size of
`FLOAT` values differently — it turns out Codepoint had a bug that
mistakenly counted them as boxed even though they are not, and `bq64b`
(same as `--enable-def-BYTE_QUOTA_MODEL=BQM_64B`) should faithfully
reproduce those numbers).

You may also omit `--enable-unicode=all` if you prefer having only the
base level of Unicode support, which you can do provided you have no
verbs in your database with Unicode characters outside of string
constants (since numeric constants cannot currently be saved as
non-ASCII digits, the only real issue here will be the existence of
Unicode identifiers in verb code).  More on this in the next section.

# Unicode support

The degree of Unicode support is governed by the `--enable-unicode`
and `--disable-unicode` command line arguments for `./configure` and
(more directly) by the `UNICODE_STRINGS`, `UNICODE_IDENTIFIERS`, and
`UNICODE_NUMBERS` settings in `options.h`

* The base server (`--disable-unicode`) now includes five new builtin
  functions `ord()`,`tochar()`, `charname()`, `encode_chars()`, and
  `decode_chars()`, for transating chars and strings.  Even though
  with this setting, the MOO language and available string constants
  remain restricted to the original all-ASCII MOO character set, this
  *can* be used to handle binary connections encoded in UTF-8 (or
  other encodings) using "binary" ('~'-escaped) strings and
  `decode_chars()` to extract the codepoint numbers (rather than
  `decode_binary()` to extract the byte values, as per the original
  prescription for dealing with binary connections) in a manner that
  is admittedly still cumbersome, but still more convenient than
  before.

* Basic Unicode support is set up by `--enable-unicode`
  a.k.a. `--enable-unicode=strings`, which is the default setting for
  server builds as of version 1.9.0.  This allows most "printable" non-ASCII
  Unicode characters to appear in database strings and MOO-language
  string constants.  This means they can now be showing up in the
  return values of `tochar()` and `decode_chars()`. They can also now
  be be used directly on non-binary connections, which means they can
  now appear in and be used as arguments to `notify()`, `$do_command`,
  `$do_login_command` and `$do_out_of_band_command` and, via the
  built-in command parser, be showing up in `args`, `argstr`,
  `dobjstr`, and `iobjstr`.

  In this version of the world, the MOO programming language otherwise
  remains the traditional ASCII version, and thus, while `eval()`,
  `set_verb_code()`, and `.program` are now able to parse strings with
  non-ASCII characters in them, the use of such characters outside of
  string constants continues to be forbidden.  Verbs and properties
  whose names contain non-ASCII characters will only be referenceable
  via indirect syntax `o.("💩")` and `o:("💩")(@args)`.  The
  functions `tonum()`, `toobj()`, and `tofloat()` continue to only
  recognize ASCII decimal digits when attempting to parse numbers out
  of strings.

* `--enable-unicode=ids` extends the MOO programming language to allow
  non-ASCII codepoints in verbcode identifiers, meaning variable names
  and direct-syntax verb/property references ("direct syntax" meaning,
  `a.Σ` as opposed to the indirect syntax `a.("Σ")`) become possible
  (`a.💩` will never be allowed because `💩` is not in the character
  class XID_START [sorry])

* `--enable-unicode=numbers` extends the MOO programming language to
  allow non-ASCII decimal digits in numeric constants and enables
  `tonum()`, `toobj()`, and `tofloat()` to recognize non-ASCII digits
  in string arguments.

  One change from the Codepoint version is that all digits in a given
  number are required to be from the same digit family.  For example,
  `tonum("13༥")`, a possibly-sneaky attempt to pass off a Tibetan 5 as
  a 4, will now fail to parse in 1.9.0.  You can still use Tibetan
  digits if you want, but the number has to be *entirely* Tibetan
  digits (so `tonum("135") == tonum("༡༣༥")` will work).

  Note that since numeric constants, once parsed, do not currently
  retain their source character set, even if one introduces non-ASCII
  constants into verbcode, they will still be unparsed back as ASCII
  digits on the first database save or on any call to `verb_code()`
  and thus non-ASCII digits currently cannot persist in numeric
  constants in any database file.

* `--enable-unicode=all` or, equivalently,
  `--enable-unicode=strings,ids,numbers` enables *all* of the Unicode
  options.

> [!WARNING]
>
> Certain aspects of Unicode support are currently deemed
> **experimental** and will likely change in future versions:

Particular issues under consideration are as follows:

* Currently, as of 1.9.0., the "printable" MOO character set for the
  Unicode-enabled server includes everything in the legal Unicode
  range except for surrogates, the "non-character" (permanently
  reserved forever) characters (0xFE, 0xFF, 0x1FE, ...), and the ASCII
  codepoints already excluded by the traditional MOO language (control
  characters other than TAB).  Further exclusions are likely in order
  to better adhere to current Unicode best practices concerning whitespace
  and line breaking, including but not necessarily limited to

  + the non-ASCII control characters (0x80-0x9f) and

  + the additional Unicode linebreaking characters
    LS (0x2028, line separator) and
	PS (0x2029, paragraph separator)
	which will likely be treated as linebreaks on non-binary connections.

  __For now, use of these characters should be avoided and it is
  possible future server versions will not preserve them.__

  Treating VERTICAL TAB (0xb) and FORM FEED (0xc) characters as
  line-breaks on non-binary connections is also under consideration;
  this should be less of an issue since these characters have
  historically been ignored on connections and forbidden in MOO
  language strings.

* String relational operators, matching of strings to verb and
  property names, and the string matching done by the built-in command
  parser, which currently follows what the 1.8.3 Codepoint server did,
  is all currently unorthodox in taking no account of canonical or
  compatibility equivalence, and in not attempting any case-folding
  for non-ASCII characters even though matching of ASCII characters
  *does* remain case-insensitive.

  __Verb code that currently depends on case-insensitive relational
  operators being case-sensitive for non-ASCII characters, or on
  canonically equivalent or compatible strings comparing as different
  will likely behave differently in future server versions.__

  (In theory, if you cared about case-sensitivity, you were already
  using `strcmp()` instead of `==`,`<`,...).

  There are also related questions concerning how `strsub()` should
  work that have yet to be resolved.

* Corresponding issues arise for identifier matching in MOO language
  source when Unicode identifiers are enabled, though since the
  identifier character set is already restricted to the XID_START and
  XID_CONTINUE classes, the ultimate resolution here may be different
  (there being various simpler options available in this case that won't
  work for the general case).

  Given that the current state of affairs in 1.9.0 with
  `--enable-unicode=ids` treating compatible identifiers, which in
  many cases will be visually identical, as different, __it is
  strongly recommended that you not enable recognition of Unicode
  identifiers if you do not have to__ (i.e., leave `UNICODE_IDENTIFERS`
  #undefed / do not use `--enable-unicode=ids`).

# Historical material

See [`README.1997`](./README.1997) for Pavel Curtis' original
`README`, which has important information for people living in 1997
and may also be an interesting window on the world of 25 years ago for
the rest of us, what with its references to ancient operating systems,
FTP servers, mailing lists, and physical addresses that no longer
exist.
