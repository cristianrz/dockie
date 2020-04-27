# shellcheck shell=sh

_POCKER_PREFIX="$HOME/.local"

export POCKER_IMAGES="$_POCKER_PREFIX/var/lib/pocker/images"
[ -d "$POCKER_IMAGES" ] || mkdir -p "$POCKER_IMAGES"

export POCKER_GUESTS="$_POCKER_PREFIX/var/lib/pocker/guests"
[ -d "$POCKER_GUESTS" ] || mkdir -p "$POCKER_GUESTS"

export REMOTE_LIBRARY="https://cristianrz.github.io/pocker-hub/library"

# _help()
# Show help and exit
_pocker_usage() {
	cat <<'EOF' >&2

Usage: pocker [OPTIONS] COMMAND [ARG...]

Docker-like interface for unprivileged chroots

Options:
    -D        Debug mode
	-h        Print usage
	-v        Print version information and quit

Commands:
	exec      Run a command in a root filesystem
	images    List images
	ls        List root filesystems
	pull      Pull an image
	rename    Rename a root filesystem
	rm        Remove one or more root filesystems
	run       Run a command in a new root filesystem
	search    Search the pocker hub for images

Run 'pocker COMMAND' for more information on a command.
EOF
	exit 1
}

[ "$#" -eq 0 ] && _pocker_usage
[ "$1" = "-v" ] && echo "Pocker version v0.1.0" && exit 0
[ "$1" = "-D" ] && set -x && shift

cmd="$1"
shift

_"$cmd" "$@"
