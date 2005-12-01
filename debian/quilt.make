#
# This file tries to mimick /usr/share/dpatch/dpatch.make
#

# -*- Makefile -*-, you silly Emacs!
# vim: set ft=make:

# QUILT_STAMPFN: stamp file to use
QUILT_STAMPFN	?= stamp-patched

# QUILT_PATCH_DIR: where the patches live
QUILT_PATCH_DIR ?= debian/patches

patch: $(QUILT_STAMPFN)
$(QUILT_STAMPFN):
	# quilt exits with 2 as return when there was nothing to do. 
	# That's not an error here (but it's usefull to break loops in crude scripts)
	QUILT_PATCHES=$(QUILT_PATCH_DIR) quilt push -a || test $$? = 2
	touch debian/$(QUILT_STAMPFN)

unpatch:
	QUILT_PATCHES=$(QUILT_PATCH_DIR) quilt pop -a -R || test $$? = 2 
	rm -rf .pc debian/$(QUILT_STAMPFN)

