PACKAGE :=	quilt
VERSION :=	0.21
RELEASE :=	1

prefix :=	/usr/local
bindir :=	$(prefix)/bin
datadir :=	$(prefix)/share
mandir :=	$(datadir)/man
docdir :=	$(datadir)/doc/packages

QUILT_DIR =	$(datadir)/$(PACKAGE)
LIB_DIR =	$(datadir)/$(PACKAGE)/lib

CFLAGS =	-g -Wall

#-----------------------------------------------------------------------
DIRT +=		$(shell find -name '*~')

SRC +=		COPYING AUTHORS TODO BUGS Makefile \
		quilt.spec.in quilt.spec quilt.changes
DIRT +=		quilt.spec

BIN_IN :=	quilt
BIN_SRC :=	$(BIN_IN:%=%.in) guards
BIN :=		$(BIN_IN) guards
SRC +=		$(BIN_SRC:%=bin/%)
DIRT +=		$(BIN_IN:%=bin/%)

QUILT_IN :=	add applied delete diff files import new next patches \
		pop previous push refresh remove rest series setup top

QUILT_SRC :=	$(QUILT_IN:%=%.in)
QUILT :=	$(QUILT_IN)
SRC +=		$(QUILT_SRC:%=quilt/%)
DIRT +=		$(QUILT_IN:%=quilt/%)

LIB_IN :=	apatch rpatch patchfns 
LIB_SRC :=	$(LIB_IN:%=%.in) parse-patch spec2series \
		backup-files.c
LIB :=		$(LIB_IN) parse-patch spec2series backup-files
SRC +=		$(LIB_SRC:%=lib/%)
DIRT +=		$(LIB_IN:%=lib/%) lib/backup-files{,.o}

DOC_IN :=	README
DOC_SRC :=	$(DOC_IN:%=%.in)
DOC :=		$(DOC_IN) docco.txt
SRC +=		$(DOC_SRC) docco.txt
DIRT +=		$(DOC_IN)

MAN1 :=		bin/guards.1

DEBIAN :=	changelog control copyright docs prerm rules 

SRC +=		$(DEBIAN:%=debian/%)

#-----------------------------------------------------------------------

all : scripts

scripts : $(BIN:%=bin/%) $(QUILT:%=quilt/%) $(LIB:%=lib/%) \
	  $(DOC) $(MAN1)

README : README.in
	@awk '/@REFERENCE@/ { system("$(MAKE) -s reference") ; next }'$$'\n'' \
			   { print }' 2>&1 $< > $@

.PHONY :: reference
reference : $(QUILT:%=quilt/%)
	@for i in $+; \
	do \
		echo "$$i >> README" >&2; \
		echo; \
		(bash -c ". lib/patchfns ; . $$i -h"); \
	done | \
	awk '/Usage:/	{ sub(/Usage: ?/, "") ; print ; next } '$$'\n'' \
	     		{ printf "  %s\n", $$0 }'
		
bin/guards.1 : bin/guards
	mkdir -p $$(dirname $@)
	pod2man $< > $@

dist : spec
	rm -f $(PACKAGE)-$(VERSION)
	ln -s . $(PACKAGE)-$(VERSION)
	tar cvfz $(PACKAGE)-$(VERSION).tar.gz \
		$(SRC:%=$(PACKAGE)-$(VERSION)/%)
	rm -f $(PACKAGE)-$(VERSION)

install : all
	install -d $(BUILD_ROOT)$(bindir)
	install -m 755 $(BIN:%=bin/%) $(BUILD_ROOT)$(bindir)/

	install -d $(BUILD_ROOT)$(QUILT_DIR)
	install -m 755 $(QUILT:%=quilt/%) $(BUILD_ROOT)$(QUILT_DIR)/

	install -d $(BUILD_ROOT)$(LIB_DIR)
	install -m 755 $(filter-out lib/patchfns lib/backup-files, \
			 $(LIB:%=lib/%)) $(BUILD_ROOT)$(LIB_DIR)/
	install -m 644 lib/patchfns $(BUILD_ROOT)$(LIB_DIR)/
	install -m 755 -s lib/backup-files $(BUILD_ROOT)$(LIB_DIR)/

	install -d $(BUILD_ROOT)$(docdir)/$(PACKAGE)
	install -m 644 README $(BUILD_ROOT)$(docdir)/$(PACKAGE)/

	install -d $(BUILD_ROOT)$(mandir)/man1
	install -m 644 $(MAN1) $(BUILD_ROOT)$(mandir)/man1/

spec : $(PACKAGE).spec
$(PACKAGE).spec : $(PACKAGE).spec.in $(PACKAGE).changes
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
	| lib/parse-patch -u changelog $@

clean distclean :
	rm -f $(DIRT)

% : %.in
	@echo "$< -> $@"
	@sed -e "s:@LIB@:$(LIB_DIR):g" \
	     -e "s:@QUILT@:$(QUILT_DIR):g" \
	     $< > $@
	@chmod --reference=$< $@
