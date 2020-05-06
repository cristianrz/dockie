#!/bin/sh
OBJ = get.sh bootstrap.sh date.sh exec.sh image.sh log.sh ls.sh pull.sh rm.sh run.sh strings.sh main.sh
PREFIX = ${HOME}/.local

all: dockie

dockie: $(OBJ) Makefile
	@./link-scripts $(OBJ) > dockie
	@shellcheck dockie
	@chmod +x dockie
	@echo dockie

install:
	@mkdir -p $(DESTDIR)$(PREFIX)/bin
	@cp dockie $(DESTDIR)$(PREFIX)/bin
	@echo $(DESTDIR)$(PREFIX)/bin/dockie

clean:
	rm -f dockie
