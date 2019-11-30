SOURCES   = $(wildcard */Makefile)
SYNCABLES = $(patsubst %/Makefile, sync-%, $(SOURCES))
SETUPABLES = $(patsubst %/Makefile, setup-%, $(SOURCES))

setup: $(SETUPABLES)

setup-%: %/Makefile
	$(MAKE) -C $* setup

sync: $(SYNCABLES)

sync-%: %/Makefile
	$(MAKE) -C $* sync
