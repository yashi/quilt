# Common rules to handle a debian package using the quilt patch utility

patch:
	[ -L patches ] || ln -s debian/patches patches
	quilt push -a

unpatch:
	if [ -L patches ] ; then \
	  quilt pop -a; \
	  rm patches; \
	fi
	rm -rf .pc
