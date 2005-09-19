dnl Process this file with autoconf to produce a configure script.
AC_INIT([quilt],[0.42],[quilt-dev@nongnu.org])
AC_CONFIG_AUX_DIR(config)
AC_PREREQ(2.53)
AC_REVISION ($Revision: 1.55 $)

PACKAGE_RELEASE=1
AC_SUBST(PACKAGE_RELEASE)

dnl Setup for backup-files compilation
AC_HEADER_STDC
AC_CHECK_FUNCS([fchmod chmod])
AC_CHECK_FUNCS([mkstemp mktemp], break)
AC_CHECK_FUNCS([mkdir rmdir])
AC_CHECK_FUNCS([strchr strrchr])
AC_CHECK_FUNCS([strerror])
AC_C_CONST
AC_FUNC_STAT

if test "$ac_compiler_gnu" = "yes"; then
  CFLAGS="$CFLAGS -Wall"
fi
EXEEXT="$ac_cv_exeext"
AC_SUBST(EXEEXT)

AC_PROG_INSTALL

AC_SYS_INTERPRETER
if test "$interpval" != yes ; then
	AC_MSG_WARN([no

bash/perl scripts may not be invoked correctly due to problems with your 
systems implementation of #! being either broken or non-existant.
])
fi

dnl Check for Bourne-Again Shell
unset BASH  # bash sets this itself!

QUILT_COMPAT_PROG_PATH(BASH, bash)

# It would be nice not to have to use backticks, but too many retarded sh
# implementations still don't support $( )
# BEWARE:  There is a distinct possibility that we are currently running under
# bash in this configure script (/bin/sh being a symlink to /bin/bash).  Even
# though the result /could/ be available to us directly as $BASH_VERSION we
# don't want to use, or trust it, incase the user is specifying a different
# bash executable.
if `$BASH -c '[[ "$BASH_VERSION" \< "2.04" ]]'` ; then
    AC_MSG_ERROR([
$PACKAGE_NAME requires at least version 2.04 of bash, you can download a current
version of bash from ftp.gnu.org
])
fi

QUILT_COMPAT_PROG_PATH(PERL, perl, [perl perl5])
QUILT_COMPAT_PROG_PATH(GREP, grep)
QUILT_COMPAT_PROG_PATH(TAIL, tail)

# Solaris' /usr/bin/tail doesn't understand -n.
AC_MSG_CHECKING([whether $TAIL -n works])
if test "`(echo first; echo second) | $TAIL -n 1 2>/dev/null`" == "second"; then
	AC_MSG_RESULT(yes)
else
	AC_MSG_RESULT(no)
	AC_MSG_ERROR([
Sorry, you have a version of tail which doesn't understand -n.
$PACKAGE_NAME needs it.  If you have access to a version of tail which does
understand -n, you can supply its path with the '--with-tail=' option.
Solaris users can use /usr/xpg4/bin/tail.
])
fi

QUILT_COMPAT_PROG_PATH(SED, sed)
QUILT_COMPAT_PROG_PATH(AWK, awk, [gawk awk])
QUILT_COMPAT_PROG_PATH(POD2MAN, pod2man)
QUILT_COMPAT_PROG_PATH(COLUMN, column)
QUILT_COMPAT_PROG_PATH(GETOPT, getopt)

if test -z "$INTERNAL_GETOPT"; then
  AC_MSG_CHECKING(for getopt --long syntax)
  dnl check GNU syntax
  $GETOPT -o t --long test -- --test | grep -q 'illegal option'
  getopt_long_errors=$?
  $GETOPT -o t --long test -- --test | grep -q '^ *--test *--'
  getopt_long_works=$?
  if test $getopt_long_errors -eq 1 -a $getopt_long_works -eq 0; then
    AC_MSG_RESULT(yes)
  else
    AC_MSG_RESULT(no)
    AC_MSG_ERROR([
$GETOPT does not support the --long option.
If you don't have a version of getopt that supports long options, you
can specify '--with-getopt=none' and $PACKAGE_NAME will use its own
internal getopt.
])
  fi
fi

QUILT_COMPAT_PROG_PATH(MKTEMP, mktemp)
if test -z "$INTERNAL_MKTEMP" ; then
    AC_MSG_CHECKING(whether $MKTEMP -d works)
    if tempdir=`$MKTEMP -d /tmp/$PACKAGE_NAME.XXXXXX 2>/dev/null` && \
       rmdir "$tempdir" ; then
	AC_MSG_RESULT(yes)
    else
	AC_MSG_RESULT(no)
	AC_MSG_ERROR([
'$MKTEMP -d' does not create temporary directories.
If you don't have a version of mktemp that can create directories, you
can specify '--with-mktemp=none' and $PACKAGE_NAME will use its own
internal tempfile generation mechanism.
])
    fi
fi

QUILT_COMPAT_PROG_PATH(DIFF, diff)
QUILT_COMPAT_PROG_PATH(PATCH, patch)

# Sun's patch is a mess, issue a warning.  But we are going to continue with
# the build because you might just be lucky.
AC_MSG_CHECKING([whether $PATCH will work])
if $PATCH -v 2>&1 | grep -q "Sun" >/dev/null 2>&1; then
	AC_MSG_RESULT(no)
	AC_MSG_WARN([
Sorry, you have a Sun version of patch which is notoriously buggy.  $PACKAGE_NAME
may function correctly, or minor errors may occur due to Sun's patch tool.
Please consider upgrading to GNU patch, if you already have GNU patch then you
can supply its path with the '--with-patch=' option.
])
elif $PATCH --version 2>&1 | grep -q "patch 2.0" >/dev/null 2>&1; then
	AC_MSG_RESULT(no)
	AC_MSG_WARN([
Sorry, the version of patch you are using can cause severe problems when a patch
creates a directory.  $PACKAGE_NAME may well function correctly with this version
of patch or small problems could creep in.
Please consider upgrading your patch to a more recent version, if you already 
have a more recent version of patch then you can supply its path with the 
'--with-patch=' option.
])
else
	AC_MSG_RESULT(yes)
fi

AC_ARG_WITH(diffstat, AC_HELP_STRING(
    [--with-diffstat], [name of the diffstat executable to use]),
    [
       DIFFSTAT="$withval"
       AC_SUBST(DIFFSTAT)
       AC_MSG_NOTICE([Using diffstat executable $DIFFSTAT])
    ],[
       AC_PATH_PROG(DIFFSTAT, diffstat)
    ])
if test -z "$DIFFSTAT"; then
    AC_MSG_WARN([
diffstat utility not found; the --diffstat option of the refresh command
will not work correctly until diffstat is installed. If you have diffstat
in a directory that is not in the search path you can specify its location
using the '--with-diffstat' option.
])
    DIFFSTAT="diffstat"
elif test "$DIFFSTAT" != no; then
    # We need diffstat version 1.32 or better, else quilt refresh --diffstat
    # will show progress data we don't want to see.  This is only a warning
    # and we continue even if version is older, as this is only a minor
    # annoyance.
    AC_MSG_CHECKING([for diffstat version])
    diffstat_major_version=`$DIFFSTAT -V 2>/dev/null | \
	sed 's/^[[^0-9]]*\([[0-9]]*\)\.\([[0-9]]*\)/\1/'`
    diffstat_minor_version=`$DIFFSTAT -V 2>/dev/null | \
	sed 's/^[[^0-9]]*\([[0-9]]*\)\.\([[0-9]]*\)/\2/'`
    if test -z "$diffstat_major_version" -o -z "$diffstat_minor_version"; then
	AC_MSG_RESULT(unknown)
	AC_MSG_WARN([
diffstat utility version couldn't be checked; chances are good that the
--diffstat option of the refresh and diff commands will not work properly.
])
    else
	AC_MSG_RESULT($diffstat_major_version.$diffstat_minor_version)
	if test "$diffstat_major_version" -lt 1 \
	   -o \( "$diffstat_major_version" -eq 1 -a "$diffstat_minor_version" -lt 32 \); then
	    AC_MSG_WARN([
diffstat utility is too old; the --diffstat option of the refresh command
will not work correctly until a newer version (>= 1.32) is installed.
])
	fi
    fi
fi

QUILT_COMPAT_PROG_PATH(SENDMAIL, [sendmail], [], [/usr/sbin])

AC_ARG_ENABLE(nls, AC_HELP_STRING(
    [--enable-nls], [include natural language support]))
if test "$enableval" != "no"; then
    AC_PATH_PROG(MSGFMT, msgfmt)
fi
if test "$enableval" = "yes" -a -z "$MSGFMT" ; then
    AC_MSG_ERROR([
You do not appear to have msgfmt, which is part of the GNU Gettext package.  It
is a required package as you chose the '--enable-nls' option to configure.
You can download GNU Gettext from ftp.gnu.org
])
fi
if test -z "$MSGFMT" ; then
    AC_MSG_NOTICE([Building without natural language support])
fi

dnl Determine where package documentation is supposed to go
if test -n "$RPM_DOC_DIR" ; then
    docdir="$RPM_DOC_DIR"
else
    docdir='$(datadir)/doc'
fi
AC_SUBST(docdir)

dnl Check for rpmbuild (v4) vs. rpm (v3)
AC_PATH_PROGS(RPMBUILD, [rpmbuild rpm])
AC_SUBST(RPMBUILD)

AC_SUBST(COMPAT_SYMLINKS)
AC_SUBST(COMPAT_PROGRAMS)

AC_CONFIG_FILES(Makefile)
AC_OUTPUT

dnl Print results
AC_MSG_RESULT([])
AC_MSG_RESULT([$PACKAGE_NAME version $PACKAGE_VERSION configured.])
AC_MSG_RESULT([])
AC_MSG_RESULT([Using '$prefix' for installation prefix.])

# we don't need to see this just for the backup-files command
# but we may as well spec it for the future
#AC_MSG_RESULT([Using '$CC' for C compiler.])
#AC_MSG_RESULT([Building with '$CFLAGS' for C compiler flags.])
#AC_MSG_RESULT([Building with '$LIBS' for linker flags.])

AC_MSG_RESULT([])
AC_MSG_RESULT([Report bugs to $PACKAGE_BUGREPORT])
