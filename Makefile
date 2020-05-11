OBJ = dockie.sh get-lxc.sh
PREFIX = ${HOME}/.local

all: dockie

dockie: $(OBJ) Makefile
	echo "#!/bin/sh" > dockie
	sed "s/^/# /g" LICENSE >> dockie
	echo >> dockie
	echo "set -eu" >> dockie
	echo >> dockie
	cat get-lxc.sh >> dockie
	cat dockie.sh >> dockie
	chmod +x dockie

install:
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp -p dockie $(DESTDIR)$(PREFIX)/bin
	@# cp -p contrib/docker-hub-pull $(DESTDIR)$(PREFIX)/bin

clean:
	rm -f dockie

uninstall:
	rm $(DESTDIR)$(PREFIX)/bin/dockie
	rm $(DESTDIR)$(PREFIX)/bin/docker-hub-pull
