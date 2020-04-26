DST = ${HOME}

all: pocker
	
pocker: pocker.sh
	shellcheck -x pocker.sh
	cat pocker.sh > pocker
	chmod +x pocker

install: 
	mv pocker $(DST)/bin/pocker

clean:
	rm -f pocker
