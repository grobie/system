SOURCES     = $(shell find . -type f ! -path ./Makefile)
DESTINATION = $(HOME)
SYNCABLES   = $(patsubst ./%, $(DESTINATION)/%, $(SOURCES))

sync: $(SYNCABLES)

$(DESTINATION)/%: %
	mkdir -p $(dir $@)
	ln -s $(abspath $<) $@
