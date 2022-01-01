#!/bin/sh

set -eu

get_graboid() {
	if [ ! -f graboid ]; then
		curl -L 'https://github.com/blacktop/graboid/releases/download/0.15.8/graboid_0.15.8_linux_x86_64.tar.gz' > graboid.tgz
		tar xzvf graboid.tgz graboid
		rm ./graboid*gz
	fi
}

get_proot() {
	if [ ! -f proot ]; then
		curl -L 'https://github.com/proot-me/proot/releases/download/v5.2.0/proot-v5.2.0-x86_64-static' > proot
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
	echo "[+] Building AppImage..."
	mkdir -p "AppDir/usr/bin"
	cp ../src/dockie-* ../src/dockie "AppDir/usr/bin"
	ARCH=x86_64 linuxdeploy \
		--appdir AppDir \
		-d ../src/dockie.desktop \
		--custom-apprun ../src/AppRun \
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
