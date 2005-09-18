dnl Allow configure to specify a specific binary
dnl 1: Environment variable
dnl 2: binary name
dnl 3: optional list of alternatives
AC_DEFUN([QUILT_COMPAT_PROG_PATH],[
  m4_define([internal_$2_cmd],[esyscmd(ls compat/$2.in 2>/dev/null)])

  AC_ARG_WITH($2, AC_HELP_STRING(
    [--with-$2], [name of the $2 executable to use]
                 m4_if(internal_$2_cmd,[],[],[ (or 'none'
                          to use an internal mechanism)])),
  [
    if test ! x"$withval" = xnone; then
      $1="$withval"
      AC_MSG_NOTICE([Using $2 executable $$2])
      COMPAT_SYMLINKS="$COMPAT_SYMLINKS $2"
    fi
  ],[
    AC_PATH_PROG($1, m4_if([$3],[],[$2],[$3]))
  ])
  if test -z "$$1"; then
    m4_if(internal_$2_cmd,[],[
      AC_MSG_ERROR([Please specify the location of $2 with the option '--with-$2'])
    ],[
      AC_MSG_WARN([Using internal $2 mechanism.  Use option '--with-$2' to override])
      COMPAT_PROGRAMS="$COMPAT_PROGRAMS $2"
      $1=$2
    ])
  fi
  AC_SUBST($1)
])
