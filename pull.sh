# shellcheck shell=sh
# Usage: dockie pull [OPTIONS] NAME
#
# Pull an image or a repository from a registry' >&2
#

_pull_error() {
	rm -rf "${DOCKIE_IMAGES:?}/$system"
	_log_fatal "pull failed for $system"
}

_pull() {
	[ "$#" -ne 1 ] && _print_usage "pull"

	system="$1"

	bootstrap="$REMOTE/$system/bootstrap"

	rm -rf "${DOCKIE_IMAGES:?}/$system"
	mkdir -p "$DOCKIE_IMAGES/$system"

	echo "Pulling from dockie-hub/$system"

	# shellcheck disable=SC2015
	tar_url="$(_get_url "$system")" &&
		wget "$tar_url" -P "$DOCKIE_IMAGES/$system" &&
		wget -q "$bootstrap" -P "$DOCKIE_IMAGES/$system" ||
		_pull_error

	echo "Downloaded rootfs for $system"
}
