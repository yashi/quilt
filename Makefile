PACKAGE :=	quilt
VERSION :=	0.21
RELEASE :=	1

prefix :=	/usr/local
bindir :=	$(prefix)/bin
datadir :=	$(prefix)/share
mandir :=	$(datadir)/man
docdir :=	$(datadir)/doc/packages

QUILT_DIR =	$(datadir)/$(PACKAGE)
SCRIPTS_DIR =	$(QUILT_DIR)/scripts
LIB_DIR =	$(prefix)/lib/$(PACKAGE)

PERL :=		/usr/bin/perl
BASH :=		/bin/bash
DIFF :=		/usr/bin/diff
PATCH :=	/usr/bin/patch
MKTEMP :=	/bin/mktemp

CFLAGS =	-g -Wall

#-----------------------------------------------------------------------
DIRT +=		$(shell find -name '*~')

SRC +=		COPYING AUTHORS TODO BUGS Makefile \
		quilt.spec.in quilt.spec quilt.changes
DIRT +=		quilt.spec

BIN_IN :=	quilt guards
BIN_SRC :=	$(BIN_IN:%=%.in)
BIN :=		$(BIN_IN)
SRC +=		$(BIN_SRC:%=bin/%)
DIRT +=		$(BIN_IN:%=bin/%)

QUILT_IN :=	add applied delete diff files import new next patches \
		pop previous push refresh remove series setup top unapplied

QUILT_SRC :=	$(QUILT_IN:%=%.in)
QUILT :=	$(QUILT_IN)
SRC +=		$(QUILT_SRC:%=quilt/%)
DIRT +=		$(QUILT_IN:%=quilt/%)

SCRIPTS_IN :=	apatch rpatch patchfns parse-patch spec2series
SCRIPTS_SRC :=	$(SCRIPTS_IN:%=%.in)
SCRIPTS :=	$(SCRIPTS_IN)
SRC +=		$(SCRIPTS_SRC:%=scripts/%)
DIRT +=		$(SCRIPTS_IN:%=scripts/%)

LIB_SRC :=	backup-files.c
LIB :=		backup-files
SRC +=		$(LIB_SRC:%=lib/%)
DIRT +=		lib/backup-files{,.o}

DOC_IN :=	README
DOC_SRC :=	$(DOC_IN:%=doc/%.in)
DOC :=		$(DOC_IN)
SRC +=		$(DOC_SRC) doc/docco.txt
DIRT +=		$(DOC_IN:%=doc/%)

MAN1 :=		bin/guards.1

DEBIAN :=	changelog control copyright docs prerm rules 

SRC +=		$(DEBIAN:%=debian/%)

#-----------------------------------------------------------------------

all : scripts

scripts : $(BIN:%=bin/%) $(QUILT:%=quilt/%) $(SCRIPTS:%=scripts/%) \
	  $(LIB:%=lib/%) $(DOC:%=doc/%) $(MAN1)

dist : $(PACKAGE)-$(VERSION).tar.gz

rpm : $(PACKAGE)-$(VERSION).tar.gz
	rpm -tb $<

doc/README : doc/README.in
	@awk '/@REFERENCE@/ { system("$(MAKE) -s reference") ; next }'$$'\n'' \
			   { print }' 2>&1 $< > $@

.PHONY :: reference
reference : $(QUILT:%=quilt/%)
	@for i in $+; \
	do \
		echo "$$i >> README" >&2; \
		echo; \
		(bash -c ". scripts/patchfns ; . $$i -h"); \
	done | \
	awk '/Usage:/	{ sub(/Usage: ?/, "") ; print ; next } '$$'\n'' \
	     		{ printf "  %s\n", $$0 }'
		
bin/guards.1 : bin/guards
	mkdir -p $$(dirname $@)
	pod2man $< > $@

$(PACKAGE)-$(VERSION).tar.gz : $(SRC)
	rm -f $(PACKAGE)-$(VERSION)
	ln -s . $(PACKAGE)-$(VERSION)
	tar cfz $(PACKAGE)-$(VERSION).tar.gz \
		$(+:%=$(PACKAGE)-$(VERSION)/%)
	rm -f $(PACKAGE)-$(VERSION)
	@echo "File $@ created."

install : all
	install -d $(BUILD_ROOT)$(bindir)
	install -m 755 $(BIN:%=bin/%) $(BUILD_ROOT)$(bindir)/

	install -d $(BUILD_ROOT)$(QUILT_DIR)
	install -m 755 $(QUILT:%=quilt/%) $(BUILD_ROOT)$(QUILT_DIR)/
	
	install -d $(BUILD_ROOT)$(SCRIPTS_DIR)
	install -m 755 $(filter-out scripts/patchfns, $(SCRIPTS:%=scripts/%)) \
		$(BUILD_ROOT)$(SCRIPTS_DIR)
	install -m 644 scripts/patchfns $(BUILD_ROOT)$(SCRIPTS_DIR)

	install -d $(BUILD_ROOT)$(LIB_DIR)
	install -m 755 -s $(LIB:%=lib/%) $(BUILD_ROOT)$(LIB_DIR)/

	install -d $(BUILD_ROOT)$(docdir)/$(PACKAGE)
	install -m 644 doc/README $(BUILD_ROOT)$(docdir)/$(PACKAGE)/

	install -d $(BUILD_ROOT)$(mandir)/man1
	install -m 644 $(MAN1) $(BUILD_ROOT)$(mandir)/man1/

$(PACKAGE).spec : $(PACKAGE).spec.in $(PACKAGE).changes Makefile \
		  scripts/parse-patch
	@echo "Generating spec file"
	@sed -e 's/^\(Version:[ \t]*\).*/\1$(VERSION)/' \
	    -e 's/^\(Release:[ \t]\).*/\1$(RELEASE)/' \
	    < $< > $@
	@perl -ne ' \
		m/^(|-+)$$/ and next; \
		( \
		  s/^(...) \s (...) \s (.\d) \s (\d\d:\d\d:\d\d) \s \
		     (...) \s (\d\d\d\d) \s - \s (.+) \
		   /* $$1 $$2 $$3 $$6 - $$7/x || \
		  m/^(- |  )(?!\s)/ \
		  and print \
		) or die "Syntax error in line $$. of changelog:\n$$_\n"; \
	' $(PACKAGE).changes \
	| scripts/parse-patch -u changelog $@

clean distclean :
	rm -f $(DIRT)

% : %.in
	@echo "$< -> $@"
	@sed -e "s:@LIB@:$(LIB_DIR):g" \
	     -e "s:@QUILT@:$(QUILT_DIR):g" \
	     -e "s:@SCRIPTS@:$(SCRIPTS_DIR):g" \
	     -e "s:@PERL@:$(PERL):g" \
	     -e "s:@BASH@:$(BASH):g" \
	     -e "s:@DIFF@:$(DIFF):g" \
	     -e "s:@PATCH@:$(PATCH):g" \
	     -e "s:@MKTEMP@:$(MKTEMP):g" \
	     $< > $@
	@chmod --reference=$< $@
