#
# spec file for patch scripts
#
# Copyright (c) 2002 SuSE Linux AG, Nuernberg, Germany.
# This file and all modifications and additions to the pristine
# package are under the same license as the package itself.
#
# Please submit bugfixes or comments via http://www.suse.de/feedback/
#

# neededforbuild fileutils make sed
# usedforbuild

Name:		patch-scripts
Summary:	Scripts for working with series of patches
License:	GPL
Group:		Productivity/Text/Utilities
Version:	0.11
Release:	1
Requires:	textutils diffutils patch gzip bzip2 perl mktemp
Autoreqprov:	off
Source:		patch-scripts-%{version}.tar.gz
BuildRoot:	%{_tmppath}/%{name}-%{version}-build
BuildArchitectures: noarch

%description
The scripts allow to manage a series of patches by keeping
track of the changes each patch makes. Patches can be
applied, un-applied, refreshed, etc.

The scripts are heavily based on Andrew Morton's patch scripts
found at http://www.zip.com.au/~akpm/linux/patches/.

Authors:
--------
    Andrew Morton <akpm@digeo.com>
    Andreas Gruenbacher <agruen@suse.de>

%prep
%setup

%build
make prefix=/usr BUILD_ROOT=$RPM_BUILD_ROOT

%install
make install prefix=/usr BUILD_ROOT=$RPM_BUILD_ROOT

%files
%defattr(-, root, root)
/usr/bin/newpatch
/usr/bin/patchadd
/usr/bin/pushpatch
/usr/bin/poppatch
/usr/bin/refpatch
/usr/bin/importpatch
/usr/bin/toppatch
/usr/bin/inpatch

/usr/share/patch-scripts/patchfns
/usr/share/patch-scripts/apatch
/usr/share/patch-scripts/rpatch
/usr/share/patch-scripts/touched-by-patch
/usr/share/patch-scripts/parse-patch
/usr/share/patch-scripts/backup-files

%doc /usr/share/doc/packages/patch-scripts/README
%doc /usr/share/doc/packages/patch-scripts/docco.txt

%changelog -n star
* Mon Jan 13 2002 - agruen
- Initial package
