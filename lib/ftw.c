/*
 * Written by Jesper Juhl <jj@dif.dk> - released under the terms of the GPL
 *
 * Credit should be given to :
 * R. Stevens author of "Advanced Programming in the UNIX Environment"
 * since I have made heavy use of some of his example code.
 *
 */

/* To compile the test code: gcc -DTEST_FTW ftw.c */

#include "ftw.h"

static int depth;
static char *path;

static int trawl(char *path, ftw_func *f, int d) {
	int		retval;
	struct stat	sb;
	struct dirent	*dir;
	DIR		*dp;
	char		*p;

	if (depth == d)
		return(0);

	if (lstat(path, &sb) == -1)
		return(f(path, &sb, FTW_NS));

	if (!S_ISDIR(sb.st_mode))
		return(f(path, &sb, FTW_F));

	if ((retval = f(path, &sb, FTW_D)) != 0)
		return(retval);

	p = path + strlen(path);
	*p++ = '/';
	*p = '\0';

	if ((dp = opendir(path)) == NULL)
		return(f(path, &sb, FTW_DNR));

	while ((dir = readdir(dp)) != NULL) {
		if ((strncmp(dir->d_name, ".", 1) == 0) ||
		    (strncmp(dir->d_name, "..", 2) == 0))
			continue;

		strcpy(p, dir->d_name);
		depth++;
		if ((retval = trawl(path, f, d)) != 0)
			break;
		depth--;
	}

	p[-1] = '\0';

	closedir(dp);
	return(retval);
}

int ftw(const char *directory, ftw_func *f, int d) {
	int	retval;

	if ((path = (char *)malloc(sysconf(_PC_PATH_MAX)+1)) == NULL)
		return(-1);

	strcpy(path, directory);
	depth = 0;
	retval = trawl(path, f, d);

	free(path);
	return(retval);
}

#ifdef TEST_FTW
int foo(const char *file, struct stat *sb, int flag) {

	switch (flag) {
		case FTW_F :
			if (S_ISREG(sb->st_mode)) printf("%s is a regular file\n\n", file);
			else if (S_ISBLK(sb->st_mode)) printf("%s is a block dev\n\n", file);
			else if (S_ISCHR(sb->st_mode)) printf("%s is a char dev\n\n", file);
			else if (S_ISFIFO(sb->st_mode)) printf("%s is a fifo\n\n", file);
			else if (S_ISLNK(sb->st_mode)) printf("%s is a link\n\n", file);
			break;
		case FTW_D :
			printf("%s is a directory\n\n", file);
			break;
		case FTW_NS :
			printf("stat failed on %s\n\n", file);
			break;
		case FTW_DNR :
			printf("%s is a directory which can't be read\n\n", file);
			break;
		default :
			printf("%s is unknown\n\n", file);
			break;
	}
	return(0);
}

int main(int argc, char *argv[]) {

	if (argc == 2) {
		ftw(argv[1], foo, 1);
		exit(0);
	} else if (argc > 2) {
		ftw(argv[1], foo, atoi(argv[2]));
		exit(0);
	} else {
		printf("usage %s <dirname> [depth]\n", argv[0]);
		exit(1);
	}
}
#endif

