#!/bin/sh

get_graboid() {
	case "$OS" in
	desktop)
		if [ ! -f graboid ]; then
			curl -L "https://github.com/blacktop/graboid/releases/download/0.15.8/graboid_0.15.8_linux_$ARCH2.tar.gz" >graboid.tgz
			tar xzvf graboid.tgz graboid
			rm ./graboid*gz
		fi
		;;
	android)
		trap 'rm -rf /tmp/graboid'
		pkg install golang -y
		cd /tmp
		git clone https://github.com/blacktop/graboid
		cd graboid
		go build
		cp graboid "$PREFIX/bin"
		;;
	esac
}

get_proot() {
	case "$OS" in
	desktop)
		if [ ! -f proot ]; then
			curl -L "https://github.com/proot-me/proot/releases/download/v5.3.0/proot-v5.3.0-$ARCH-static" >proot
			chmod +x proot
		fi
		;;
	android)
		pkg install proot
		;;
	esac
}

make_image() {
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

set -eu

HERE="$(pwd)"

# get architecture
ARCH="$(uname -m)" export ARCH

# some executables call aarch64 as arm64
case "$ARCH" in
aarch64) ARCH2=arm64 ;;
*) ARCH2="$ARCH" ;;
esac

# check if it's android or "normal" Linux
OS="desktop"
case "$(uname -a)" in
*android*) OS="android" ;;
esac

case "${1-}" in
clean) clean ;;
"")
	mkdir -p build
	cd build

	echo "[+] Getting proot..." >&2
	get_proot
	echo "[+] Getting graboid..." >&2
	get_graboid

	# AppImages don't build on ARCH other than x86_64
	case "$ARCH" in
	x86_64) make_image ;;
	*)
		# other functions change directory previously
		cd "$HERE"
		mkdir -p "${PREFIX-$HOME}"/bin
		install -m 755 build/proot build/graboid "${PREFIX-$HOME}"/bin
		install -m 755 src/dockie src/dockie-* "${PREFIX-$HOME}"/bin
		{
			echo "[+] All done!"
			echo
			echo "You can now run \`dockie\`"
		} >&2
		;;
	esac
	;;
*) echo 'unrecognised argument' >&2 && exit 1 ;;
esac
