SOURCES     = $(wildcard *.json)
DESTINATION = $(HOME)/.config/Code/User
SYNCABLES   = $(patsubst %, $(DESTINATION)/%, $(SOURCES))

sync: $(SYNCABLES)

$(DESTINATION)/%: %
	mkdir -p $(dir $@)
	ln -s $(abspath $<) $@
