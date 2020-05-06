# Set to either "lxc" or "docker"
HUB = docker

OBJ = get-$(HUB).sh bootstrap.sh date.sh exec.sh image.sh log.sh ls.sh pull.sh rm.sh run.sh strings.sh main.sh
PREFIX = ${HOME}/.local

all: dockie 

dockie: $(OBJ) Makefile
	@./link-scripts $(OBJ) > dockie
	@shellcheck dockie
	@chmod +x dockie

install:
	@mkdir -p $(DESTDIR)$(PREFIX)/bin
	@cp dockie $(DESTDIR)$(PREFIX)/bin
	@cp docker-hub-pull $(DESTDIR)$(PREFIX)/bin

clean:
	rm -f dockie
