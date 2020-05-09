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
#	exec      Run a command in a root filesystem
#	image     List images
#	ls        List root filesystems
#	pull      Pull an image
#	rm        Remove one or more root filesystems
#	run       Run a command in a new root filesystem
#	search    Search the image server for images
#
# Run 'dockie COMMAND' for more information on a command.
#

VERSION="v0.6.0"

DOCKIE_PREFIX="$HOME/.local"

DOCKIE_IMAGES="$DOCKIE_PREFIX/var/lib/dockie/images"
mkdir -p "$DOCKIE_IMAGES"

DOCKIE_GUESTS="$DOCKIE_PREFIX/var/lib/dockie/guests"
mkdir -p "$DOCKIE_GUESTS"

_print_usage() {
	# grab usages from comments
	_log_fatal "$(awk '
	/^# Usage: dockie '"$1"'/, $0 !~ /^#/ {
		if ( $0 ~ /^#/ ) {
			gsub(/# ?/,"")
			print
		}
	}
	' "$0")"
}

[ "$#" -eq 0 ] && _print_usage "\[O"
[ "$1" = "-v" ] && echo "Dockie version $VERSION" && exit 0
[ "$1" = "-d" ] && set -x && shift

cmd="_$1" && shift
type "$cmd" >/dev/null 2>&1 || _print_usage "\[O"
"$cmd" "$@"
