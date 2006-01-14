TESTS=$(shell ls -tr *.test)

QUILTRC=$(CURDIR)/test.quiltrc
QUILT=$(CURDIR)/../quilt
LIB=$(CURDIR)/../lib
export QUILTRC QUILT LIB
PATH:=$(CURDIR)/../bin:$(PATH)
ifneq ($(shell . $(QUILTRC) ;  echo $$QUILT_PATCHES_PREFIX),)
P=patches/
_P=../patches/
export P _P
endif

all: $(TESTS) remove_symlink

.PHONY: $(TESTS)

$(TESTS): scripts_symlink
	@echo "[$@]"
	@LANG=POSIX ./run $@

scripts_symlink:
	@[ -e ../quilt/scripts ] || ln -s ../scripts ../quilt/scripts

remove_symlink:
	@rm -f quilt/scripts
