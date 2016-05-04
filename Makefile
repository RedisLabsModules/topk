all: librmutil topk

clean:
	$(MAKE) -C rmutil clean
	$(MAKE) -C src clean

.PHONY: topk
topk:
	$(MAKE) -C src

.PHONY: librmutil
librmutil:
	$(MAKE) -C rmutil
