TESTS=$(wildcard *.test)

all: $(patsubst %,_test_%,$(TESTS))

.PHONY: $(patsubst %,_test_%,$(TESTS))
$(patsubst %,_test_%,$(TESTS)):
	@test=$(patsubst _test_%,%,$@); \
	echo "[$$test]" ; \
	export QUILTRC=$(CURDIR)/test.quiltrc ; \
	./run $$test
