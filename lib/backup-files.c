/* backup-files.c
   Andreas Gruenbacher, 18 January 2003

   `patch -b' fails to back up files correctly if a file occurs
   more than once in a patch, so we use this utility instead.
*/

/*
 - catch SIGINT
 - remove backup files and directories
*/

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <errno.h>
#include <string.h>

const char *progname;

void
usage(void)
{
	printf("Usage: %s [-B prefix] [-z suffix] [-f filelist] [-s] [-r|-x]\n"
	       "\n"
	       "\tCreate hard linked backup copies of a list of files\n"
	       "\tread from standard input.\n"
	       "\n"
	       "\t-r\tRestore the backup\n"
	       "\t-x\tRemove backup files and empty parent directories\n"
	       "\t-B\tPath name prefix for backup files\n"
	       "\t-z\tPath name suffix for backup files\n"
	       "\t-s\tSilent operation; only print error messages\n\n",
	       progname);
}

void
create_parents(char *filename)
{
	struct stat st;
	char *f = strchr(filename, '/');

	if (f == NULL)
		return;
	*f = '\0';
	if (stat(f, &st) != 0) {
		while (f != NULL) {
			*f = '\0';
			mkdir(filename, 0777);
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
	char *f;

	while ((f = strrchr(filename, '/')) != NULL) {
		*f = '\0';
		rmdir(filename);
	}
}

enum { what_backup, what_restore, what_remove };

#define LINE_LENGTH 1024

int
main(int argc, char *argv[])
{
	char orig[LINE_LENGTH], *o, backup[LINE_LENGTH];
	FILE *file;

	const char *opt_prefix="", *opt_suffix="", *opt_file=NULL;
	int opt_silent=0, opt_what=what_backup;
	int opt, status=0;
	
	progname = argv[0];

	while ((opt = getopt(argc, argv, "rxB:z:f:sh")) != -1) {
		switch(opt) {
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

			case 'z':
				opt_suffix = optarg;
				break;

			case 's':
				opt_silent = 1;
				break;

			case 'h':
			default:
				usage();
				return 0;
		}
	}

	if ((*opt_prefix == '\0' && *opt_suffix == '\0') || optind != argc) {
		usage();
		return 1;
	}

	if (opt_file != NULL) {
		if ((file = fopen(opt_file, "r")) == NULL) {
			perror(opt_file);
			return 1;
		}
	} else {
		file = stdin;
	}

	while (fgets(orig, sizeof(orig), file)) {
		if (strlen(opt_prefix) + strlen(orig) + strlen(opt_suffix) >=
		    sizeof(backup)) {
			perror("Line buffer too small\n");
			return 1;
		}

		o = strchr(orig, '\0');
		if (o > orig && *(o-1) == '\n')
			*(o-1) = '\0';
		if (*orig == '\0')
			continue;
			
		snprintf(backup, sizeof(backup), "%s%s%s",
			 opt_prefix, orig, opt_suffix);

		if (opt_what == what_backup) {
			int fd;
			create_parents(backup);

			if (link(orig, backup) == 0) {
				if (!opt_silent)
					printf("Copying %s\n", orig);
			} else if ((fd = creat(backup, 0666)) != -1) {
				close(fd);
				if (!opt_silent)
					printf("New file %s\n", orig);
			} else {
				perror(backup);
				return 1;
			}
		} else if (opt_what == what_restore) {
			struct stat st;

			create_parents(orig);

			if (stat(backup, &st) != 0) {
				perror(backup);
				status=1;
				continue;
			}
			if (st.st_size == 0) {
				if (unlink(orig) == 0 || errno == ENOENT) {
					if (!opt_silent)
						printf("Removing %s\n", orig);
					unlink(backup);
					remove_parents(backup);
				} else {
					if (errno != ENOENT) {
						perror(orig);
						status=1;
					}
				}
			} else {
				unlink(orig);
				if (link(backup, orig) == 0) {
					if (!opt_silent)
						printf("Restoring %s\n", orig);
					unlink(backup);
					remove_parents(backup);
				} else {
					fprintf(stderr, "Could not restore "
						      "file `%s' to `%s': %s\n",
						backup, orig, strerror(errno));
					status=1;
				}
			}
		} else {
			unlink(backup);
			remove_parents(backup);
		}
	}

	if (file != stdin) {
		fclose(file);
	}

	return status;
}
