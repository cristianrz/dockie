# shellcheck shell=sh
# Usage: pocker rm [OPTIONS] ROOTFS [ROOTFS...]
#
# Remove one or more rootfs.
#

_rm() {
	[ "$#" -eq 0 ] && _print_usage rm

	cd "$POCKER_GUESTS" || exit 1

	for fs; do
		[ ! -d "$POCKER_GUESTS/$fs" ] && \
			_log_fatal "Error: No such container: $fs"
		chmod -R +w "$fs" && rm -r "$fs" && echo "$fs"
	done
}
