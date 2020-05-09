# shellcheck shell=sh
# Usage: dockie image COMMAND
#
# Manage images
#
# Commands:
#   ls    List images
#   pull  Pull an image
#   rm    Remove one or more images" >&2
#
_image() {
	[ "$#" -eq 0 ] && ls -1 "$DOCKIE_IMAGES" && exit 0

	[ "$1" != "rm" ] && _print_usage "image"

	[ "$#" -ne 2 ] && _print_usage "image rm"

	[ ! -d "$DOCKIE_IMAGES/$2" ] &&
		_log_fatal "no such guest: $2"

	rm -rf "${DOCKIE_IMAGES:?}/$2"
}

_images() {
	_image "$@"
}

# Usage: dockie image rm [OPTIONS] ROOTFS
#
# Remove one or more rootfs'.
#
