MDMAN = pandoc
MDMANFLAGS = -s -f markdown -t man

OBJ = dockie.sh get-lxc.sh
PREFIX ?= /usr/local

all: dockie dockie.1

dockie: $(OBJ) Makefile
	@echo "#!/bin/sh" > dockie
	@sed "s/^/# /g" LICENSE >> dockie
	@echo >> dockie
	@grep -v 'shellcheck shell=' get-lxc.sh >> dockie
	@grep -v 'shellcheck shell=' dockie.sh >> dockie

dockie.1: dockie.1.md
	@$(MDMAN) $(MDMANFLAGS) -o dockie.1 dockie.1.md
	@echo dockie.1

install:
	@mkdir -p $(DESTDIR)$(PREFIX)/bin
	@mkdir -p $(DESTDIR)$(PREFIX)/share/man/man1
	@cp dockie $(DESTDIR)$(PREFIX)/bin
	@cp dockie.1 $(DESTDIR)$(PREFIX)/share/man/man1
	@# cp -p contrib/docker-hub-pull $(DESTDIR)$(PREFIX)/bin
	@chmod 755 $(DESTDIR)$(PREFIX)/bin/dockie
	@chmod 644 $(DESTDIR)$(PREFIX)/share/man/man1/dockie.1
	@echo $(DESTDIR)$(PREFIX)/bin/dockie
	@echo $(DESTDIR)$(PREFIX)/share/man/man1/dockie.1


clean:
	rm -f dockie dockie.1

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/dockie
	rm -f $(DESTDIR)$(PREFIX)/bin/docker-hub-pull
	rm -f $(DESTDIR)$(PREFIX)/share/man/man1/dockie.1

.PHONY: all install clean uninstall
