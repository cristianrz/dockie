# shellcheck shell=sh
# Usage: dockie pull [OPTIONS] NAME
#
# Pull an image or a repository from a registry
#

_pull_error() {
	rm -rf "${DOCKIE_IMAGES:?}/$system"
	_log_fatal "pull failed for $system"
}

_pull() {
	[ "$#" -ne 1 ] && _print_usage "pull"

	system="$1"

	rm -rf "${DOCKIE_IMAGES:?}/${system##*/}"
	mkdir -p "$DOCKIE_IMAGES/${system##*/}"

	# shellcheck disable=SC2015
	_get "$DOCKIE_IMAGES/${system##*/}" "$system" || _pull_error

	echo "Downloaded rootfs for $system"
}
