# shellcheck shell=sh
# Usage: dockie run [OPTIONS] SYSTEM [COMMAND] [ARG...]
#
# Run a command in a new rootfs
#
# Options:
#     --name string    Assign a name to the container'
#

_run_error_existing() {
	_log_fatal "dockie: The container name '$1' is already in use."
}

_run() {
	[ "$#" -eq 0 ] && _print_usage "run"

	echo Bootstraping... This may take a few minutes.

	[ "$1" = "--name" ] && shift && guest_name="$1" && shift

	system_name="$1" && shift

	# need a guest name if the user did not specify any
	: "${guest_name=$system_name}"

	[ -d "$DOCKIE_GUESTS/$guest_name" ] &&
		_run_error_existing "$guest_name"

	mkdir -p "$DOCKIE_GUESTS/$guest_name/rootfs"

	_bootstrap "$system_name" "$DOCKIE_GUESTS/$guest_name"

	[ "$#" -ne 0 ] && _exec "$guest_name" "$@"
}
