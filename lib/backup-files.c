/*
  File: backup-files.c

  Copyright (C) 2003 Andreas Gruenbacher <agruen@suse.de>
  SuSE Labs, SuSE Linux AG

  This program is free software; you can redistribute it and/or
  modify it under the terms of the GNU Library General Public
  License as published by the Free Software Foundation; either
  version 2 of the License, or (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Library General Public License for more details.

  You should have received a copy of the GNU Library General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
*/

/*
 * Create backup files of a list of files similar to GNU patch. A path
 * name prefix and suffix for the backup file can be specified with the
 * -B and -Z options.
 */

#define _GNU_SOURCE

#include <sys/types.h>
#include <sys/stat.h>
#include <utime.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <alloca.h>
#include <ftw.h>

const char *progname;

enum { what_noop, what_backup, what_restore, what_remove };

const char *opt_prefix="", *opt_suffix="", *opt_file;
int opt_silent, opt_what=what_noop, opt_ignore_missing;
int opt_nolinks, opt_touch;

#define LINE_LENGTH 1024


void
usage(void)
{
	printf("Usage: %s [-B prefix] [-z suffix] [-f {filelist|-}] [-s] [-b|-r|-x] [-L] {filename|-} ...\n"
	       "\n"
	       "\tCreate hard linked backup copies of a list of files\n"
	       "\tread from standard input.\n"
	       "\n"
	       "\t-b\tCreate backup\n"
	       "\t-r\tRestore the backup\n"
	       "\t-x\tRemove backup files and empty parent directories\n"
	       "\t-B\tPath name prefix for backup files\n"
	       "\t-z\tPath name suffix for backup files\n"
	       "\t-s\tSilent operation; only print error messages\n"
	       "\t-L\tEnsure that when finished, the source file has a link count of 1\n\n",
	       progname);
}

void
create_parents(const char *filename)
{
	struct stat st;
	char *fn = alloca(strlen(filename) + 1), *f;

	strcpy(fn, filename);
	f = strchr(fn, '/');

	if (f == NULL)
		return;
	*f = '\0';
	if (stat(f, &st) != 0) {
		while (f != NULL) {
			*f = '\0';
			mkdir(fn, 0777);
			*f = '/';
			f = strchr(f+1, '/');
		}
	} else {
		*f = '/';
	}
}

void
remove_parents(char *filename)
{
	char *f, *g = NULL;

	f = strrchr(filename, '/');
	while ((f = strrchr(filename, '/')) != NULL) {
		if (g != NULL)
			*g = '/';
		g = f;
		*f= '\0';
		
		rmdir(filename);
	}
	if (g != NULL)
		*g = '/';
}

static int
copy(int from_fd, int to_fd)
{
	char buffer[4096];
	size_t len;

	while ((len = read(from_fd, buffer, sizeof(buffer))) > 0) {
		if ((write(to_fd, buffer, len)) == -1)
			return 1;
	}
	return (len != 0);
}

static int
link_or_copy(const char *from, struct stat *st, const char *to)
{
	int from_fd, to_fd, error = 1;

	if (link(from, to) == 0)
		return 0;
	if (errno != EXDEV && errno != EPERM && errno != EMLINK) {
		fprintf(stderr, "Could not link file `%s' to `%s': %s\n",
		       from, to, strerror(errno));
		return 1;
	}

	if ((from_fd = open(from, O_RDONLY)) == -1) {
		perror(from);
		return 1;
	}
	unlink(to);  /* make sure we don't inherit this file's mode. */
	if ((to_fd = creat(to, st->st_mode))) {
		perror(to);
		close(from_fd);
		return 1;
	}
	(void) fchmod(to_fd, st->st_mode);
	if (copy(from_fd, to_fd)) {
		fprintf(stderr, "%s -> %s: %s\n", from, to, strerror(errno));
		unlink(to);
		goto out;
	}

	error = 0;
out:
	close(from_fd);
	close(to_fd);

	return error;
}

static int
ensure_nolinks(const char *filename)
{
	struct stat st;

	if (stat(filename, &st) != 0) {
		perror(filename);
		return 1;
	}
	if (st.st_nlink > 1) {
		char *tmpname = malloc(1 + strlen(filename) + 7 + 1), *c;
		int from_fd = -1, to_fd = -1;
		int error = 1;

		if (!tmpname)
			goto fail;
		from_fd = open(filename, O_RDONLY);
		if (from_fd == -1)
			goto fail;
		
		/* Temp file name is "path/to/.file.XXXXXX" */
		strcpy(tmpname, filename);
		strcat(tmpname, ".XXXXXX");
		c = strrchr(tmpname, '/');
		if (c == NULL)
			c = tmpname;
		else
			c++;
		memmove(c + 1, c, strlen(c) + 1);
		*c = '.';
		
		to_fd = mkstemp(tmpname);
		if (to_fd == -1)
			goto fail;
		if (copy(from_fd, to_fd))
			goto fail;
		(void) fchmod(to_fd, st.st_mode);
		if (rename(tmpname, filename))
			goto fail;

		error = 0;
	fail:
		if (error)
			perror(filename);
		free(tmpname);
		close(from_fd);
		close(to_fd);
		return error;
	} else
		return 0;
}

int
process_file(const char *file)
{
	char *backup = alloca(strlen(opt_prefix) + strlen(file) +
			      strlen(opt_suffix) + 1);

	sprintf(backup, "%s%s%s", opt_prefix, file, opt_suffix);

	if (opt_what == what_backup) {
		struct stat st;
		int missing_file = (stat(file, &st) == -1 && errno == ENOENT);

		unlink(backup);
		create_parents(backup);
		if (missing_file) {
			int fd;

			if (!opt_silent)
				printf("New file %s\n", file);
			/* GNU patch creates new files with mode==0. */
			if ((fd = creat(backup, 0)) == -1) {
				perror(backup);
				return 1;
			}
			close(fd);
		} else {
			if (!opt_silent)
				printf("Copying %s\n", file);
			if (link_or_copy(file, &st, backup))
				return 1;
			if (opt_touch)
				utime(backup, NULL);
			if (opt_nolinks) {
				if (ensure_nolinks(file))
					return 1;
			}
		}
		return 0;
	} else if (opt_what == what_restore) {
		struct stat st;

		create_parents(file);
		if (stat(backup, &st) != 0) {
			if (opt_ignore_missing && errno == ENOENT)
				return 0;
			perror(backup);
			return 1;
		}
		if (st.st_size == 0) {
			if (unlink(file) == 0 || errno == ENOENT) {
				if (!opt_silent)
					printf("Removing %s\n", file);
			} else {
				perror(file);
				return 1;
			}
		} else {
			if (!opt_silent)
				printf("Restoring %s\n", file);
			unlink(file);
			if (link_or_copy(backup, &st, file))
				return 1;
			if (opt_touch)
				utime(file, NULL);
			if (opt_nolinks) {
				if (ensure_nolinks(file))
					return 1;
			}
		}
		if (!(st.st_mode & S_IWUSR)) {
			/* Change mode of backup file so that we
			   can later remove it. */
			chmod(backup, st.st_mode | S_IWUSR);
		}
		unlink(backup);
		remove_parents(backup);
		return 0;
	} else if (opt_what == what_remove) {
		/* Change mode of backup file so that we can remove it. */
		chmod(backup, S_IWUSR);
		unlink(backup);
		remove_parents(backup);
		return 0;
	} else if (opt_what == what_noop) {
		struct stat st;
		int missing_file = (stat(file, &st) == -1 && errno == ENOENT);

		if (!missing_file && opt_nolinks) {
			if (ensure_nolinks(file))
				return 1;
		}
		return 0;
	} else
		return 1;
}

int
walk(const char *path, const struct stat *stat, int flag, struct FTW *ftw)
{
	size_t prefix_len=strlen(opt_prefix), suffix_len=strlen(opt_suffix);
	size_t len = strlen(path);
	char *p;

	if (flag == FTW_DNR) {
		perror(path);
		return 1;
	}
	if (!S_ISREG(stat->st_mode))
		return 0;
	if (strncmp(opt_prefix, path, prefix_len))
		return 0;  /* prefix does not match */
	if (len < suffix_len || strcmp(opt_suffix, path + len - suffix_len))
		return 0;  /* suffix does not match */

	p = alloca(len - prefix_len - suffix_len + 1);
	memcpy(p, path + prefix_len, len - prefix_len - suffix_len);
	p[len - prefix_len - suffix_len] = '\0';
	return process_file(p);
}

int
main(int argc, char *argv[])
{
	int opt, status=0;
	
	progname = argv[0];

	while ((opt = getopt(argc, argv, "brxB:z:f:shFLt")) != -1) {
		switch(opt) {
			case 'b':
				opt_what = what_backup;
				break;

			case 'r':
				opt_what = what_restore;
				break;

			case 'x':
				opt_what = what_remove;
				break;

			case 'B':
				opt_prefix = optarg;
				break;
				
			case 'f':
				opt_file = optarg;
				break;

			case 'F':  /* ignore missing input files */
				opt_ignore_missing = 1;
				break;

			case 'z':
				opt_suffix = optarg;
				break;

			case 's':
				opt_silent = 1;
				break;

			case 'L':
				opt_nolinks = 1;
				break;

			case 't':
				opt_touch = 1;
				break;

			case 'h':
			default:
				usage();
				return 0;
		}
	}

	if ((*opt_prefix == '\0' && *opt_suffix == '\0') ||
	    (opt_file == NULL && optind == argc)) {
		usage();
		return 1;
	}

	if (opt_file != NULL) {
		FILE *file;
		char line[LINE_LENGTH];

		if (!strcmp(opt_file, "-")) {
			file = stdin;
		} else {
			if ((file = fopen(opt_file, "r")) == NULL) {
				perror(opt_file);
				return 1;
			}
		}

		while (fgets(line, sizeof(line), file)) {
			char *l = strchr(line, '\0');

			if (l > line && *(l-1) == '\n')
				*(l-1) = '\0';
			if (*line == '\0')
				continue;
				
			if ((status = process_file(line)) != 0)
				return status;
		}

		if (file != stdin) {
			fclose(file);
		}
	}
	for (; optind < argc; optind++) {
		if (strcmp(argv[optind], "-") == 0) {
			char *dir = strdup(opt_prefix), *d = strrchr(dir, '/');
			if (d)
				*(d+1) = '\0';
			else
				d = ".";
			status = nftw(dir, walk, 0, 0);
			free(dir);
		} else
			status = process_file(argv[optind]);
		if (status)
			return status;
	}

	return status;
}
