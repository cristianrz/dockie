# shellcheck shell=sh
# Usage: dockie rm [OPTIONS] ROOTFS [ROOTFS...]
#
# Remove one or more rootfs.
#
_rm() {
	[ "$#" -eq 0 ] && _print_usage rm

	cd "$DOCKIE_GUESTS" || exit 1

	for fs; do
		[ ! -d "$fs" ] &&
			_log_fatal "no such container: $fs"
		[ -e "$fs/lock" ] &&
			_log_fatal "guest is currently in use, otherwise" \
			"delete $DOCKIE_GUESTS/$fs/lock manually"
		chmod -R +w "$fs" && rm -r "$fs"
	done
}
