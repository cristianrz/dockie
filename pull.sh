# shellcheck shell=sh
# Usage: dockie pull [OPTIONS] NAME
#
# Pull an image or a repository from a registry
#

# _pull(system)
_pull() {
	[ "$#" -ne 1 ] && _print_usage "pull"

	image_path="$DOCKIE_IMAGES/$1"

	_strings_contains "$1" ':' ||
		_log_fatal "need to specify image:version"

	rm -rf "${image_path:?}"
	mkdir -p "$image_path"

	# shellcheck disable=SC2015
	_get "$image_path" "$1" || {
		rm -rf "${DOCKIE_IMAGES:?}/$system" &&
			_log_fatal "pull failed for $system"
	}

	echo "Downloaded rootfs for $1"
}
