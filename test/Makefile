TESTS=$(shell ls -tr *.test)

export QUILTRC=$(CURDIR)/test.quiltrc
ifneq ($(shell source $(QUILTRC) ;  echo $$QUILT_PATCHES_PREFIX),)
export P=patches/
endif
$(warning P=$(P))

all: $(TESTS)

.PHONY: $(TESTS)

$(TESTS):
	@echo "[$@]"
	@./run $@
