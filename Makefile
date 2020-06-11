OBJ = dockie.sh get-lxc.sh
PREFIX ?= /usr/local

all: dockie dockie.1

dockie: $(OBJ) Makefile
	@echo "#!/bin/sh" > dockie
	@sed "s/^/# /g" LICENSE >> dockie
	@echo >> dockie
	@grep -v 'shellcheck shell=' get-lxc.sh >> dockie
	@grep -v 'shellcheck shell=' dockie.sh >> dockie

install:
	@mkdir -m 755 -p $(DESTDIR)$(PREFIX)/bin
	@mkdir -m 755 -p $(DESTDIR)$(PREFIX)/lib/dockie
	@mkdir -m 755 -p $(DESTDIR)$(PREFIX)/share/man/man1
	@cp dockie                  $(DESTDIR)$(PREFIX)/bin
	@# cp contrib/docker-hub-pull $(DESTDIR)$(PREFIX)/lib/dockie
	@cp dockie.1                $(DESTDIR)$(PREFIX)/share/man/man1
	@chmod 755 $(DESTDIR)$(PREFIX)/bin/dockie
	@# chmod 644 $(DESTDIR)$(PREFIX)/lib/dockie/docker-hub-pull
	@chmod 644 $(DESTDIR)$(PREFIX)/share/man/man1/dockie.1

clean:
	rm -f dockie

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/dockie
	rm -f $(DESTDIR)$(PREFIX)/lib/dockie/docker-hub-pull
	rmdir $(DESTDIR)$(PREFIX)/lib/dockie
	rm -f $(DESTDIR)$(PREFIX)/share/man/man1/dockie.1

.PHONY: all install clean uninstall
