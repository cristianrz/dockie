#!/bin/sh

set -eu

ARCH="$(uname -m)" export ARCH

case "$ARCH" in
aarch64) ARCH2=arm64 ;;
*) ARCH2="$ARCH" ;;
esac

get_graboid() {
	if [ ! -f graboid ]; then
		curl -L "https://github.com/blacktop/graboid/releases/download/0.15.8/graboid_0.15.8_linux_$ARCH2.tar.gz" >graboid.tgz
		tar xzvf graboid.tgz graboid
		rm ./graboid*gz
	fi
}

get_proot() {
	if [ ! -f proot ]; then
		curl -L "https://github.com/proot-me/proot/releases/download/v5.3.0/proot-v5.3.0-$ARCH-static" >proot
		chmod +x proot
	fi
}

download() {
	echo "[+] Getting proot..."
	get_proot
	echo "[+] Getting graboid..."
	get_graboid
}

make_image() {
	case "$ARCH" in
	aarch64)
		echo "AppImage won't work here. You can copy src/dockie" \
			"src/dockie-* build/proot build/graboid to your PATH"
		exit 1
		;;
	esac

	echo "[+] Building AppImage..."
	mkdir -p "AppDir/usr/bin"
	cp ../src/dockie-* ../src/dockie "AppDir/usr/bin"
	cd AppDir
	ln -s usr/bin/dockie AppRun
	cd ..
	ARCH="$ARCH" linuxdeploy \
		--appdir AppDir \
		-d ../src/dockie.desktop \
		--output appimage \
		-i ../src/dockie-icon.png

	echo "[+] All done!"
	echo
	printf "build/"
	echo dockie*AppImage
}

clean() {
	rm -rf ./build
}

case "${1-}" in
clean) clean ;;
"")
	mkdir -p build
	cd build
	download
	make_image
	;;
*) echo 'unrecognised argument' >&2 && exit 1 ;;
esac
