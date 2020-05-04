#!/bin/sh
OBJ = header.sh bootstrap.sh exec.sh image.sh log.sh ls.sh pull.sh rm.sh run.sh main.sh
PREFIX = ${HOME}/.local

all: pocker

pocker: $(OBJ)
	@cat $(OBJ) > pocker
	@shellcheck pocker
	@chmod +x pocker
	@echo pocker

install:
	@mkdir -p $(DESTDIR)$(PREFIX)/bin
	@cp pocker $(DESTDIR)$(PREFIX)/bin
	@echo $(DESTDIR)$(PREFIX)/bin/pocker

clean:
	rm pocker
