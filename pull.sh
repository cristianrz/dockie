# shellcheck shell=sh
# Usage: pocker pull [OPTIONS] NAME
#
# Pull an image or a repository from a registry' >&2
#

_pull_network_error() {
	rm -rf "${POCKER_IMAGES:?}/$_system"
	_log_fatal "Error response: pull access denied for $_system"
}

_pull() {
	[ "$#" -ne 1 ] && _print_usage "pull"

	_system="$1"

	_bootstrap="$REMOTE_LIBRARY/$_system/bootstrap"

	rm -rf "${POCKER_IMAGES:?}/$_system"
	mkdir -p "$POCKER_IMAGES/$_system"

	echo "Pulling from pocker-hub/$_system"

	# shellcheck disable=SC2015
	_tar_url="$(wget -q -O- "$REMOTE_LIBRARY/$_system/url" | sh)" &&
		wget "$_tar_url" -P "$POCKER_IMAGES/$_system" &&
		wget -q "$_bootstrap" -P "$POCKER_IMAGES/$_system" ||
		_pull_network_error

	echo "Downloaded rootfs for $_system"
}
