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

# Usage: dockie image rm [OPTIONS] ROOTFS [ROOTFS...]
#
# Remove one or more rootfs'.
#
_image_rm() {
	[ "$#" -eq 0 ] && _print_usage "image rm"

	# just to make sure we don't delete what we shouldn't
	cd "$DOCKIE_IMAGES" || exit 1

	for fs; do
		[ ! -d "$DOCKIE_IMAGES/$fs" ] &&
			_log_fatal "Error: No such container: $fs"
		rm -rf ./"$fs" && echo "$fs"
	done
}
