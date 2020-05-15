OBJ = dockie.sh get-lxc.sh
PREFIX = ${HOME}/.local

all: dockie dockie.1.gz

dockie: $(OBJ) Makefile
	echo "#!/bin/sh" > dockie
	sed "s/^/# /g" LICENSE >> dockie
	echo >> dockie
	echo "set -eu" >> dockie
	echo >> dockie
	grep -v 'shellcheck shell' get-lxc.sh >> dockie
	grep -v 'shellcheck shell' dockie.sh >> dockie
	chmod +x dockie

dockie.1.gz: dockie.1.md
	pandoc -s -t man -f markdown -o dockie.1 dockie.1.md
	gzip -f dockie.1

install:
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp dockie $(DESTDIR)$(PREFIX)/bin
	@# cp -p contrib/docker-hub-pull $(DESTDIR)$(PREFIX)/bin
	mkdir -p $(DESTDIR)$(PREFIX)/share/man/man1
	cp dockie.1.gz $(DESTDIR)$(PREFIX)/share/man/man1

clean:
	rm -f dockie
	rm -f dockie.1.gz
	rm -f *tgz

uninstall:
	rm $(DESTDIR)$(PREFIX)/bin/dockie
	rm $(DESTDIR)$(PREFIX)/bin/docker-hub-pull
