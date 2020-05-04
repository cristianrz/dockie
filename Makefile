#!/bin/sh
OBJ = bootstrap.sh exec.sh image.sh log.sh ls.sh pull.sh rm.sh run.sh main.sh
PREFIX = ${HOME}/.local

all: pocker

pocker: $(OBJ) Makefile
	@echo '#!/usr/bin/env sh' > pocker
	@echo '#' >> pocker
	@cat LICENSE >> pocker
	@echo '#' >> pocker
	@echo '# Docker-like interface for unprivileged chroots' >> pocker
	@cat $(OBJ) >> pocker
	@shellcheck pocker
	@chmod +x pocker
	@echo pocker

install:
	@mkdir -p $(DESTDIR)$(PREFIX)/bin
	@cp pocker $(DESTDIR)$(PREFIX)/bin
	@echo $(DESTDIR)$(PREFIX)/bin/pocker

clean:
	rm -f pocker
