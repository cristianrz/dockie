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
#
_image() {
	[ "$#" -eq 0 ] && ls -1 "$DOCKIE_IMAGES" && exit 0

	cmd="$1" && shift

	_image_"$cmd" "$@" || _print_usage "image"
}

_images() {
	_image "$@"
}

# Usage: dockie image rm [OPTIONS] ROOTFS
#
# Remove one or more rootfs'.
#
_image_rm() {
	[ "$#" -ne 1 ] && _print_usage "image rm"

	[ ! -d "$DOCKIE_IMAGES/$1" ] &&
		_log_fatal "Error: No such guest: $1"

	rm -rf "${DOCKIE_IMAGES:?}/$1"
}
