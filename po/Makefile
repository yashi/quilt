QUILT_IN :=   add applied delete diff files import new next patches \
              pop previous push refresh remove series setup top unapplied
SCRIPTS_IN := apatch rpatch patchfns spec2series patchfns
# scripts/parse-patch is perl based

TO_PARSE= $(foreach f,$(QUILT_IN),../quilt/$(f).in)      \
          $(foreach f,$(SCRIPTS_IN),../scripts/$(f).in)  \
	  ../bin/quilt.in

# LINGUAS = ...
# localedir = ...

all: $(LINGUAS:%=%.mo)

%.mo : %.po
	msgfmt --statistics -o $@ $<

%.po : quilt.pot
	msgmerge -o $@ $@ $^

quilt.pot: $(TO_PARSE)
	rm -f quilt.pot; touch quilt.pot
	for file in $(TO_PARSE) ; do \
	  bash --dump-po-strings $$file \
	    |msguniq\
	    |msgcat --force-po -F - quilt.pot -o quilt.pot; \
	done

clean:
	rm -f *.mo *~

install: all
	for lang in $(LINGUAS) ; do \
		install -d $(BUILD_ROOT)$(localedir)/$$lang/LC_MESSAGES ; \
		install -m 644 $$lang.mo \
		    $(BUILD_ROOT)$(localedir)/$$lang/LC_MESSAGES/quilt.mo ; \
	done

.PHONY: install clean all
