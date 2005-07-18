# scripts/parse-patch is perl based

# LINGUAS = ...
# localedir = ...

all: $(LINGUAS:%=%.mo)

%.mo : %.po
	msgfmt --statistics -o $@ $<

%.po : quilt.pot
	msgmerge -o $@ $@ $^
	msgfmt --statistics -o /dev/null $@
	
quilt.pot: $(filter-out ../debian/control ../doc/quilt.1 ../doc/README, \
			$(patsubst %.in,%,$(wildcard ../*/*.in)))
	rm -f quilt.pot; touch quilt.pot
	( cd .. ; \
	for file in $+ ; do \
	  file=$${file#../} ; \
	  if head $$file | grep -q bash; then \
	    bash --dump-po-strings $$file ; \
	  elif head $$file | grep -q perl; then \
	    xgettext --from-code=UTF-8 --omit-header --language=Perl \
	    	     --keyword=_ -o - $$file; \
	  else \
	    echo "Don't know how to handle $$file" >&2 ; \
	    exit 1 ; \
	  fi \
	done ) \
	|msguniq \
	|msgcat --force-po -F - quilt.pot -o quilt.pot

clean:
	rm -f *.mo *~

install: all
	for lang in $(LINGUAS) ; do \
		install -d $(BUILD_ROOT)$(localedir)/$$lang/LC_MESSAGES ; \
		install -m 644 $$lang.mo \
		    $(BUILD_ROOT)$(localedir)/$$lang/LC_MESSAGES/quilt.mo ; \
	done

uninstall:
	for lang in $(LINGUAS) ; do \
		rm -f $(BUILD_ROOT)$(localedir)/$$lang/LC_MESSAGES/quilt.mo ; \
	done

.PHONY: install clean all
