# shellcheck shell=sh

# _tar_c makes up for the lack of the -C option on POSIX
_tar_c() {
	cd "$1"
	shift
	tar "$@"
}
