OBJ = tar.sh get.sh bootstrap.sh date.sh exec.sh image.sh log.sh ls.sh pull.sh rm.sh run.sh strings.sh main.sh
PREFIX = ${HOME}/.local

all:
	@echo 1. ./configure
	@echo 2. make install

install:
	@mkdir -p $(DESTDIR)$(PREFIX)/bin
	@cp dockie $(DESTDIR)$(PREFIX)/bin
	@cp contrib/docker-hub-pull $(DESTDIR)$(PREFIX)/bin

clean:
	@rm -f dockie

uninstall:
	@rm $(DESTDIR)$(PREFIX)/bin/dockie
	@rm $(DESTDIR)$(PREFIX)/bin/docker-hub-pull
