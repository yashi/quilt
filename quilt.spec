#
# spec file for quilt - patch management scripts
#
# Copyright (c) 2003 SuSE Linux AG, Nuernberg, Germany.
# This file and all modifications and additions to the pristine
# package are under the same license as the package itself.
#
# Please submit bugfixes or comments via http://www.suse.de/feedback/
#

# neededforbuild sh-utils
# usedforbuild

Name:		quilt
Summary:	Scripts for working with series of patches
License:	GPL
Group:		Productivity/Text/Utilities
Version:	0.21
Release:	1
Requires:	textutils diffutils patch gzip bzip2 perl mktemp
Autoreqprov:	off
Source:		quilt-%{version}.tar.gz
BuildRoot:	%{_tmppath}/%{name}-%{version}-build

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
if [ "${RPM_BUILD_ROOT%/}" != "" ]; then
	rm -rf $RPM_BUILD_ROOT
fi
%setup

%build
make prefix=/usr BUILD_ROOT=$RPM_BUILD_ROOT

%install
make install prefix=/usr BUILD_ROOT=$RPM_BUILD_ROOT

%files
%defattr(-, root, root)
/usr/bin/guards
/usr/bin/quilt

/usr/share/quilt/

%doc /usr/share/man/man1/guards.1.gz
%doc README

%changelog
# The changelog is kept in %{name}.changes

