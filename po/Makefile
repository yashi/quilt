QUILT_IN :=   add applied delete diff files import new next patches \
              pop previous push refresh remove series setup top unapplied
SCRIPTS_IN := apatch rpatch patchfns spec2series patchfns
# scripts/parse-patch is perl based

TO_PARSE= $(foreach f,$(QUILT_IN),../quilt/$(f).in)      \
          $(foreach f,$(SCRIPTS_IN),../scripts/$(f).in)  \
	  ../bin/quilt.in


all: fr.mo

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
	install -d $(BUILD_ROOT)/usr/share/locale/fr/LC_MESSAGES
	install -m644 fr.mo $(BUILD_ROOT)/usr/share/locale/fr/LC_MESSAGES/quilt.mo

.PHONY: install clean all
