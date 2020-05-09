# shellcheck shell=sh
# Usage: dockie pull [OPTIONS] NAME
#
# Pull an image or a repository from a registry
#

_pull_error() {
	rm -rf "${DOCKIE_IMAGES:?}/$system"
	_log_fatal "pull failed for $system"
}

# _pull(system)
_pull() {
	[ "$#" -ne 1 ] && _print_usage "pull"

	image="$1"
	image_path="$DOCKIE_IMAGES/$image"

	case "$1" in
	*:*) ;;
	*) _log_fatal "need to specify image:version" ;;
	esac

	rm -rf "${image_path:?}"
	mkdir -p "$image_path"

	# shellcheck disable=SC2015
	_get "$image_path" "$image" || _pull_error

	echo "Downloaded rootfs for $image"
}
