SCRIPTS_IN := inpatch newpatch patchadd poppatch pushpatch refpatch toppatch \
	      importpatch
LIB_SCRIPTS_IN := apatch rpatch patchfns backup-files
LIB_SCRIPTS := touched-by-patch parse-patch
#LIB_LIB := patchfns

VERSION := 0.11

prefix := /usr/local
bindir := $(prefix)/bin
datadir := $(prefix)/share
LIB := $(datadir)/patch-scripts
docdir := $(datadir)/doc/packages

CFLAGS = -Wall

% : %.in
	@echo "$< -> $@"
	@sed -e "s:@LIB@:$(LIB):g" $< > $@
	@chmod --reference=$< $@

all : scripts README

scripts : $(SCRIPTS_IN) $(LIB_SCRIPTS_IN:%=lib/%)

README : README.in
	@echo "$< -> $@"
	@awk '/@REFERENCE@/ { system("$(MAKE) -s reference") ; next }'$$'\n'' \
			   { print }' $< > $@

reference : $(SCRIPTS_IN)
	@for i in $(SCRIPTS_IN); \
	do \
		echo; \
		./$$i -h; \
	done | \
	awk '/Usage:/	{ sub(/Usage: ?/, "") ; print ; next } '$$'\n'' \
	     		{ printf "  %s\n", $$0 }'
		
dist : distclean
	rm -f patch-scripts-$(VERSION)
	ln -s . patch-scripts-$(VERSION)
	tar cvfz patch-scripts-$(VERSION).tar.gz \
		--exclude=patch-scripts-$(VERSION)/patch-scripts-* \
		--exclude=patch-scripts-$(VERSION)/CVS \
		patch-scripts-$(VERSION)/*
	rm -f patch-scripts-$(VERSION)

install : all
	install -d $(BUILD_ROOT)$(LIB)
	install -m 755 $(LIB_SCRIPTS_IN:%=lib/%) \
		$(BUILD_ROOT)$(LIB)
	install -m 755 $(LIB_SCRIPTS:%=lib/%) \
		$(BUILD_ROOT)$(LIB)
	#install -m 644 $(LIB_LIB:%=lib/%) \
	#	$(BUILD_ROOT)$(LIB)

	install -d $(BUILD_ROOT)$(bindir)
	install -m 755 $(SCRIPTS_IN) \
		$(BUILD_ROOT)$(bindir)

	install -d $(BUILD_ROOT)$(docdir)/patch-scripts
	install -m 644 README needs-checking/docco.txt \
		$(BUILD_ROOT)$(docdir)/patch-scripts

clean distclean :
	rm -f $(SCRIPTS_IN) $(LIB_SCRIPTS_IN:%=lib/%) README
