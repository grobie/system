SOURCES   = $(wildcard */Makefile)
SYNCABLES = $(patsubst %/Makefile, sync-%, $(SOURCES))

sync: $(SYNCABLES)

sync-%: %/Makefile
	$(MAKE) -C $* sync
