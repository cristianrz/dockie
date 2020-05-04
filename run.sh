# shellcheck shell=sh
# Usage: pocker run [OPTIONS] SYSTEM [COMMAND] [ARG...]
# 
# Run a command in a new rootfs
# 
# Options:
#     --name string    Assign a name to the container'
#

_run_error_existing() {
	echo "pocker: The container name '$1' is already in use." >&2 && exit 1
}

_run() {
	# Run needs at least one argument
	[ "$#" -eq 0 ] && _print_usage run

	echo Bootstraping... This may take a few minutes.

	[ "$1" = "--name" ] && shift && _guest_name="$1" && shift

	_system_name="$1" && shift

	# Need a guest name if the user did not specify any
	: "${_guest_name=$_system_name}"

	[ -d "$POCKER_GUESTS/$_guest_name" ] && _run_error_existing "$_guest_name"

	mkdir -p "$POCKER_GUESTS/$_guest_name/rootfs"

	_bootstrap "$_system_name" "$POCKER_GUESTS/$_guest_name"

	[ "$#" -eq 0 ] || _exec "$_guest_name" "$@" && exit 0
}
