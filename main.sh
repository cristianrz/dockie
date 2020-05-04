# shellcheck shell=sh
# Usage: pocker [OPTIONS] COMMAND [ARG...]
# 
# Docker-like interface for unprivileged chroots
# 
# Options:
# 	-D        Debug mode
# 	-h        Print usage
# 	-v        Print version information and quit
# 
# Commands:
# 	exec      Run a command in a root filesystem
# 	images    List images
# 	ls        List root filesystems
# 	pull      Pull an image
# 	rm        Remove one or more root filesystems
# 	run       Run a command in a new root filesystem
# 
# Run 'pocker COMMAND' for more information on a command.
#

_POCKER_PREFIX="$HOME/.local"

# need to export for bootstrap scripts
export POCKER_IMAGES="$_POCKER_PREFIX/var/lib/pocker/images"
[ -d "$POCKER_IMAGES" ] || mkdir -p "$POCKER_IMAGES"

# need to export for bootstrap scripts
export POCKER_GUESTS="$_POCKER_PREFIX/var/lib/pocker/guests"
[ -d "$POCKER_GUESTS" ] || mkdir -p "$POCKER_GUESTS"

REMOTE_LIBRARY="https://raw.githubusercontent.com/cristianrz/pocker-hub/master"


_print_usage(){
	awk '
	/^# Usage: pocker '"$1"'/, $0 !~ /^#/ {
		if ( $0 ~ /^#/ ) {
			gsub(/# ?/,"")
			print
		}
	}
	' "$0"
	exit 1
}

[ "$#" -eq 0 ] && _print_usage "\[OPT"
[ "$1" = "-v" ] && echo "Pocker version v0.1.0" && exit 0
[ "$1" = "-D" ] && set -x && shift

cmd="_$1" && shift

type "$cmd" >/dev/null 2>&1 || _print_usage "\[OPT"
"$cmd" "$@"
