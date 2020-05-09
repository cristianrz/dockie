# shellcheck shell=sh
# Usage: dockie rm [OPTIONS] ROOTFS
#
# Remove an image.
#

_rm() {
	[ "$#" -eq 0 ] && _print_usage rm

	guest_path="$DOCKIE_GUESTS/$1"

	[ ! -d "$guest_path" ] && _log_fatal "no such guest '$1'"

	[ -f "$guest_path/lock" ] && _log_fatal "guest is currently in use," \
		"otherwise do 'rm $guest_path/lock'"

	chmod -R +w "$guest_path"
	rm -r "$guest_path"
}
