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

_cdbs_patch_system_apply_rule := apply-patches
_cdbs_patch_system_unapply_rule := reverse-patches

# DEB_PATCHDIRS: directory containing your source file for patches.
DEB_PATCHDIRS = debian/patches

# DEB_QUILT_PATCHDIR_LINK
# By default, quilt expects to find the patch files into the /patches directory.
#  Since it is often more pleasant to place them into /debian/patches, a link
#  is created by this makefile chunk to fix it. 
# In the case where you already have a /patches directory in your package, 
#  redefine this variable to somewhere else, and set QUILT_PATCHES in your
#   $HOME/.quiltrc (so that quilt knows where to search for this)
DEB_QUILT_PATCHDIR_LINK = patches

# DEB_QUILT_SERIES: series file to use
DEB_QUILT_SERIES = $(DEB_PATCHDIRS)/series

# Internal variables, do not change it unless you know what you're doing
DEB_QUILT_CMD = $(if $(DEB_QUILT_PATCHDIR_LINK),QUILT_PATCHES=$(DEB_QUILT_PATCHDIR_LINK)) quilt

post-patches:: apply-patches

clean:: reverse-patches

# The patch subsystem
apply-patches: pre-build debian/stamp-patched
debian/stamp-patched: 
debian/stamp-patched:
	if [ -n "$(DEB_QUILT_PATCHDIR_LINK)" ] ; then \
	  if [ -L $(DEB_QUILT_PATCHDIR_LINK) ] ; then : ; else \
	    ln -s $(DEB_PATCHDIRS) $(DEB_QUILT_PATCHDIR_LINK) ; \
	  fi ; \
	fi
	$(DEB_QUILT_CMD) push -a
	touch debian/stamp-patched

reverse-patches:
	$(DEB_QUILT_CMD) pop -a -R
	if [ -n "$(DEB_QUILT_PATCHDIR_LINK)" ] ; then \
	  if [ -L $(DEB_QUILT_PATCHDIR_LINK) ] ; then \
	    rm $(DEB_QUILT_PATCHDIR_LINK) ; \
	  fi ; \
	fi
	rm -rf .pc
	rm -f debian/stamp-patch*

endif
