dnl Process this file with autoconf to produce a configure script.
AC_INIT([quilt],[0.22],[quilt-dev@nongnu.org])
AC_CONFIG_AUX_DIR(config)
AC_PREREQ(2.53)
AC_REVISION ($Revision: 1.5 $)

PACKAGE_RELEASE=1
AC_SUBST(PACKAGE_RELEASE)

dnl Setup for backup-files compilation
AC_HEADER_STDC
AC_CHECK_FUNCS([mkdir])
AC_CHECK_FUNCS([rmdir])
AC_CHECK_FUNCS([strchr])
AC_CHECK_FUNCS([strerror])
AC_CHECK_FUNCS([strrchr])
AC_C_CONST
AC_FUNC_STAT

AC_PROG_INSTALL

AC_SYS_INTERPRETER
if test "$interpval" != yes ; then
	AC_MSG_WARN([no

bash/perl scripts may not be invoked correctly due to problems with your 
systems implementation of #! being either broken or non-existant.
])
fi

# Check for Bourne-Again Shell
AC_ARG_WITH(bash, AC_HELP_STRING(
    [--with-bash], [name of the bash executable to use]),
    [
	BASH="$withval"
	AC_SUBST(BASH)
	AC_MSG_NOTICE([Using bash executable $BASH])
    ],[
	AC_PATH_PROG(BASH, bash)
    ])
if test -z "$BASH" ; then
    AC_MSG_ERROR([Please specify the location of bash with --with-bash])
fi

dnl Check for Perl
AC_ARG_WITH(perl, AC_HELP_STRING(
    [--with-perl], [name of the Perl executable to use]),
    [
	PERL="$withval"
	AC_SUBST(PERL)
	AC_MSG_NOTICE([Using Perl executable $PERL])
    ],[
	AC_PATH_PROGS(PERL, [perl perl5])
    ])
if test -z "$PERL" ; then
    AC_MSG_ERROR([Please specify the location of Perl with --with-perl])
fi

dnl Checks for mktemp (for creating temporary files and directories)
AC_ARG_WITH(mktemp, AC_HELP_STRING(
    [--with-mktemp], [name of the mktemp executable to use]),
    [
	MKTEMP="$withval"
	AC_SUBST(MKTEMP)
	AC_MSG_NOTICE([Using mktemp executable $MKTEMP])
    ],[
	AC_PATH_PROG(MKTEMP, mktemp)
    ])
if test -z "$MKTEMP" ; then
    AC_MSG_ERROR([Please specify the location of mktemp with --with-mktemp])
fi

AC_MSG_CHECKING(whether $MKTEMP -d works)
if tempdir=`$MKTEMP -d /tmp/$PACKAGE_NAME.XXXXXX 2>/dev/null` && \
   rmdir "$tempdir" ; then
    AC_MSG_RESULT(yes)
else
    AC_MSG_RESULT(no)
    AC_MSG_ERROR([$MKTEMP does not create temporary directories with -d])
fi

# Check for diff
AC_ARG_WITH(diff, AC_HELP_STRING(
    [--with-diff], [name of the diff executable to use]),
    [
	DIFF="$withval"
	AC_SUBST(DIFF)
	AC_MSG_NOTICE([Using diff executable $DIFF])
    ],[
	AC_PATH_PROG(DIFF, diff)
    ])
if test -z "$DIFF"; then
    AC_MSG_ERROR([Please specify the location of diff with --with-diff])
fi

# Check for patch
AC_ARG_WITH(patch, AC_HELP_STRING(
    [--with-patch], [name of the patch executable to use]),
    [
	PATCH="$withval"
	AC_SUBST(PATCH)
	AC_MSG_NOTICE([Using patch executable $PATCH])
    ],[
	AC_PATH_PROG(PATCH, patch)
    ])
if test -z "$PATCH"; then
    AC_MSG_ERROR([Please specify the location of patch with --with-patch])
fi

# Sun's patch is a mess, issue a warning.  But we are going to continue with
# the build because you might just be lucky.
AC_MSG_CHECKING([whether $PATCH will work])
if $PATCH -v 2>&1 | grep -q "Sun" >/dev/null 2>&1; then
	AC_MSG_RESULT(no)
	AC_MSG_WARN([
Sorry, you have a Sun version of patch which is notoriously buggy.  $PACKAGE
may function correctly, or minor errors may occur due to Sun's patch tool.
Please consider upgrading to GNU patch, if you already have GNU patch then you
can supply its path with the '--with-patch=' option.
])
else
	AC_MSG_RESULT(yes)
fi

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
