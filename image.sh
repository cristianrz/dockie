# shellcheck shell=sh
_image_usage() {
	echo "Usage:	pocker image COMMAND

Manage images

Commands:
  ls    List images
  pull  Pull an image
  rm    Remove one or more images" >&2
	exit 1
}

_image_rm_usage() {
	cat <<'EOF'
"pocker image rm" requires at least 1 argument.

Usage:  pocker image rm [OPTIONS] ROOTFS [ROOTFS...]

Remove one or more rootfs'.
EOF
}

_image_rm() {
	[ "$#" -eq 0 ] && _image_rm_usage && return

	cd "$POCKER_IMAGES" || exit 1

	for fs; do
		[ ! -d "$POCKER_IMAGES/$fs" ] && _log_fatal "Error: No such container: $fs" && continue
		rm -rf "$fs" && echo "$fs"
	done
}

_image_ls() {
	find "$POCKER_IMAGES" -maxdepth 1 -type d -exec basename {} \; | sed 1d
}

_image(){
    [ "$#" -eq 0 ] && _image_ls

    cmd="$1" && shift

    case "$cmd" in
    ls) _image_ls ;;
    rm) _image_rm "$@" ;;
    esac
}

_images() {
	_image "$@"
}
