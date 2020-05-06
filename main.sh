# shellcheck shell=sh
# Usage: dockie [OPTIONS] COMMAND [ARG...]
#
# Dockie is a wrapper around PRoot with a familiar interface
#
# Options:
# 	-d        Debug mode
# 	-h        Print usage
# 	-v        Print version information and quit
#
# Commands:
# 	exec      Run a command in a root filesystem
# 	image     List images
# 	ls        List root filesystems
# 	pull      Pull an image
# 	rm        Remove one or more root filesystems
# 	run       Run a command in a new root filesystem
#
# Run 'dockie COMMAND' for more information on a command.
#

VERSION="v0.4.0"

PREFIX="$HOME/.local"

# need to export for bootstrap scripts
export DOCKIE_IMAGES="$PREFIX/var/lib/dockie/images"
mkdir -p "$DOCKIE_IMAGES"

# need to export for bootstrap scripts
export DOCKIE_GUESTS="$PREFIX/var/lib/dockie/guests"
mkdir -p "$DOCKIE_GUESTS"

REMOTE="https://us.images.linuxcontainers.org/images"

_print_usage() {
	# grab usages from comments
	awk '
	/^# Usage: dockie '"$1"'/, $0 !~ /^#/ {
		if ( $0 ~ /^#/ ) {
			gsub(/# ?/,"")
			print
		}
	}
	' "$0"
	exit 1
}

[ "$#" -eq 0 ] && _print_usage "\[O"
[ "$1" = "-v" ] && echo "Dockie version $VERSION" && exit 0
[ "$1" = "-d" ] && set -x && shift

cmd="_$1" && shift
type "$cmd" >/dev/null 2>&1 || _print_usage "\[O"
"$cmd" "$@"
