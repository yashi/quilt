TESTS=$(shell ls -tr *.test)

QUILTRC=$(CURDIR)/test.quiltrc
export QUILTRC
ifneq ($(shell . $(QUILTRC) ;  echo $$QUILT_PATCHES_PREFIX),)
P=patches/
_P=../patches/
export P _P
endif
$(warning P=$(P))

all: $(TESTS)

.PHONY: $(TESTS)

$(TESTS):
	@echo "[$@]"
	@LANG=POSIX ./run $@
