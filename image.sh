# shellcheck shell=sh

# Usage: pocker image rm [OPTIONS] ROOTFS [ROOTFS...]
#
# Remove one or more rootfs'.
#
_image_rm() {
	[ "$#" -eq 0 ] &&
		echo '"pocker image rm" requires at least 1 argument.' &&
		_print_usage "image rm" &&
		return

	cd "$POCKER_IMAGES" || exit 1

	for fs; do
		[ ! -d "$POCKER_IMAGES/$fs" ] &&
			_log_fatal "Error: No such container: $fs" && continue
		rm -rf "$fs" && echo "$fs"
	done
}

_image_ls() {
	find "$POCKER_IMAGES" -maxdepth 1 -type d -exec basename {} \; | sed 1d
}

# Usage: pocker image COMMAND
#
# Manage images
#
# Commands:
#   ls    List images
#   pull  Pull an image
#   rm    Remove one or more images" >&2
#
_image() {
	[ "$#" -eq 0 ] && _image_ls && return

	cmd="$1" && shift

	_inage_"$cmd"
}

_images() {
	_image "$@"
}
