#ifndef _FTW_H_
#define _FTW_H_

#include <stdio.h>
#include <stdlib.h>
#include <dirent.h>
#include <sys/stat.h>
#include <unistd.h>
#include <string.h>
#include <limits.h>

#define FTW_F	1
#define FTW_D	2
#define FTW_DNR	3
#define FTW_NS	4

/* This is a replacement for the FTW file traversal utility */

typedef int ftw_func(const char *file, const struct stat *sb, int flag);

int ftw(const char *directory, ftw_func *f, int d);

#endif  /* _FTW_H_ */
