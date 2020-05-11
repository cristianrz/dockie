OBJ = dockie.sh get-lxc.sh
PREFIX = ${HOME}/.local

all: dockie dockie.1

dockie: $(OBJ) Makefile
	echo "#!/bin/sh" > dockie
	sed "s/^/# /g" LICENSE >> dockie
	echo >> dockie
	echo "set -eu" >> dockie
	echo >> dockie
	grep -v 'shellcheck shell' get-lxc.sh >> dockie
	grep -v 'shellcheck shell' dockie.sh >> dockie
	chmod +x dockie

dockie.1: dockie.1.md
	pandoc -s -t man -f markdown -o dockie.1 dockie.1.md

install:
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	mv dockie $(DESTDIR)$(PREFIX)/bin
	@# cp -p contrib/docker-hub-pull $(DESTDIR)$(PREFIX)/bin

clean:
	rm -f dockie

uninstall:
	rm $(DESTDIR)$(PREFIX)/bin/dockie
	rm $(DESTDIR)$(PREFIX)/bin/docker-hub-pull
