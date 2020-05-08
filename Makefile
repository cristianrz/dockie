OBJ = tar.sh get-lxc.sh bootstrap.sh date.sh exec-proot.sh image.sh log.sh ls.sh pull.sh rm.sh run.sh strings.sh main.sh
PREFIX = ${HOME}/.local

all: $(OBJ)
	echo "#!/usr/bin/env sh" > dockie
	sed "s/^/# /g" LICENSE >> dockie
	echo >> dockie
	echo "set -eu" >> dockie
	echo >> dockie
	sed '/shellcheck shell/d' tar.sh >> dockie
	sed '/shellcheck shell/d' get-lxc.sh >> dockie
	sed '/shellcheck shell/d' bootstrap.sh >> dockie
	sed '/shellcheck shell/d' date.sh >> dockie
	sed '/shellcheck shell/d' exec-proot.sh >> dockie
	sed '/shellcheck shell/d' image.sh >> dockie
	sed '/shellcheck shell/d' log.sh >> dockie
	sed '/shellcheck shell/d' ls.sh >> dockie
	sed '/shellcheck shell/d' pull.sh >> dockie
	sed '/shellcheck shell/d' rm.sh >> dockie
	sed '/shellcheck shell/d' run.sh >> dockie
	sed '/shellcheck shell/d' strings.sh >> dockie
	sed '/shellcheck shell/d' main.sh >> dockie
	chmod +x dockie
install:
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp -p dockie $(DESTDIR)$(PREFIX)/bin
	cp -p contrib/docker-hub-pull $(DESTDIR)$(PREFIX)/bin

clean:
	rm -f dockie

uninstall:
	rm $(DESTDIR)$(PREFIX)/bin/dockie
	rm $(DESTDIR)$(PREFIX)/bin/docker-hub-pull
