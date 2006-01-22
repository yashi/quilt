# -*- mode: makefile; coding: utf-8 -*-
# Copyright © 2003 Martin Quinson <martin.quinson@tuxfamily.org>
# Description: An advanced patch system based on the quilt facilities.
#  please refere to the documentation of the quilt package for more information.
#
# Used variables for configuration:
#  

#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2, or (at
# your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
# 02111-1307 USA.

ifndef _cdbs_bootstrap
_cdbs_scripts_path ?= /usr/lib/cdbs
_cdbs_rules_path ?= /usr/share/cdbs/1/rules
_cdbs_class_path ?= /usr/share/cdbs/1/class
endif

ifndef _cdbs_rules_patchsys_quilt
_cdbs_rules_patchsys_quilt := 1

ifdef _cdbs_rules_patchsys
$(error cannot load two patch systems at the same time)
endif

include $(_cdbs_rules_path)/buildcore.mk$(_cdbs_makefile_suffix)

DEB_SRCDIR ?= .

_cdbs_patch_system_apply_rule := apply-patches
_cdbs_patch_system_unapply_rule := reverse-patches

# DEB_PATCHDIRS: directory containing your source file for patches.
DEB_PATCHDIRS = $(shell pwd)/debian/patches

# DEB_QUILT_PATCHDIR_LINK
# By default, quilt expects to find the patch files into the /patches directory.
#  Since it is often more pleasant to place them into /debian/patches, a link
#  is created by this makefile chunk to fix it. 
# In the case where you already have a /patches directory in your package, 
#  redefine this variable to somewhere else, and set QUILT_PATCHES in your
#   $HOME/.quiltrc (so that quilt knows where to search for this)
DEB_QUILT_PATCHDIR_LINK = patches

# Internal variables, do not change it unless you know what you're doing
DEB_QUILT_CMD = cd $(DEB_SRCDIR) && $(if $(DEB_QUILT_PATCHDIR_LINK),QUILT_PATCHES=$(DEB_QUILT_PATCHDIR_LINK)) quilt

# Declare Build-Dep of packages using this file onto quilt
CDBS_BUILD_DEPENDS      := $(CDBS_BUILD_DEPENDS), quilt

# Build-Dep on patchutils to check for fool souls patching config.* files
# This is a Bad Thing since cdbs updates those files automatically.
#  (code stolen from cdbs itself, in dpatch.mk)

CDBS_BUILD_DEPENDS      := $(CDBS_BUILD_DEPENDS), patchutils (>= 0.2.25)

# target reverse-config, which we use, don't exist in old cdbs 
CDBS_BUILD_DEPENDS      := $(CDBS_BUILD_DEPENDS), cdbs (>= 0.4.27-1)

evil_patches_that_do_nasty_things := $(shell \
if lsdiff=`which lsdiff` ; then \
  patchlist=`$(DEB_QUILT_CMD) series \
               | sed 's|^|$(if $(DEB_QUILT_PATCHDIR_LINK),$(DEB_QUILT_PATCHDIR_LINK)/)|' \
               | tr "\n" " "`; \
  if [ "x$$patchlist" != x ] ; then \
    $$lsdiff -H $$patchlist \
    | grep "/config\.\(guess\|sub\|rpath\)$$" | tr "\n" " " ; \
  fi;\
fi)
ifneq (, $(evil_patches_that_do_nasty_things))
$(warning WARNING:  The following patches are modifying auto-updated files.  This can result in serious trouble:  $(evil_patches_that_do_nasty_things))
endif


post-patches:: apply-patches

clean:: reverse-patches

# The patch subsystem
apply-patches: pre-build debian/stamp-patched
debian/stamp-patched:
	# reverse-config must be first
	$(MAKE) -f debian/rules reverse-config
	
	if [ -n "$(DEB_QUILT_PATCHDIR_LINK)" ] ; then \
	  if [ -L $(DEB_SRCDIR)/$(DEB_QUILT_PATCHDIR_LINK) ] ; then : ; else \
	    (cd $(DEB_SRCDIR); ln -s $(DEB_PATCHDIRS) $(DEB_QUILT_PATCHDIR_LINK)) ; \
	  fi ; \
	fi
	# quilt exits with 2 as return when there was nothing to do. 
	# That's not an error here (but it's usefull to break loops in crude scripts)
	$(DEB_QUILT_CMD) push -a || test $$? = 2
	touch debian/stamp-patched
	
	$(MAKE) -f debian/rules update-config
	# update-config must be last

reverse-patches:
	# reverse-config must be first
	$(MAKE) -f debian/rules reverse-config
	
	if [ -d "$(DEB_SRCDIR)" ] ; then \
	  $(DEB_QUILT_CMD) pop -a -R || test $$? = 2 ; \
	fi 
	if [ -n "$(DEB_QUILT_PATCHDIR_LINK)" ] ; then \
	  if [ -L $(DEB_SRCDIR)/$(DEB_QUILT_PATCHDIR_LINK) ] ; then \
	    rm $(DEB_SRCDIR)/$(DEB_QUILT_PATCHDIR_LINK) ; \
	  fi ; \
	fi
	rm -rf $(DEB_SRCDIR)/.pc
	rm -f debian/stamp-patch*

endif
