#!/bin/sh
OBJ = header.sh bootstrap.sh exec.sh image.sh log.sh ls.sh pull.sh rename.sh rm.sh run.sh main.sh
DEST = ${HOME}/bin

all: pocker

pocker: $(OBJ)
	cat $(OBJ) > pocker
	shellcheck pocker
	chmod +x pocker

install:
	cp pocker $(DEST)

clean:
	rm pocker
