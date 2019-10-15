SOURCES   = $(shell find . -name '.*' -type f -print)
SYNCABLES = $(patsubst ./%, $(HOME)/%, $(SOURCES))

sync: $(SYNCABLES)

$(HOME)/%: %
	ln -s $(abspath $<) $@
