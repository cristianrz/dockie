# shellcheck shell=sh
_pull_network_error() {
	echo "Error response: pull access denied for $_system" >&2
	rm -rf "${POCKER_IMAGES:?}/$_system"
	exit 1
}

_pull_usage() {
	echo '"pocker pull" requires exactly 1 argument.

Usage:  pocker pull [OPTIONS] NAME

Pull an image or a repository from a registry' >&2
	exit 1
}

_pull() {
	[ "$#" -ne 1 ] && _pull_usage

	_system="$1"

	_url="$REMOTE_LIBRARY/$_system/url"
	_bootstrap="$REMOTE_LIBRARY/$_system/bootstrap.sh"

	rm -rf "${POCKER_IMAGES:?}/$_system"
	mkdir -p "$POCKER_IMAGES/$_system"

	echo "Pulling from pocker-hub/$_system"

	# the url is inside the 'url' file
	_tar_url="$(wget -O- "$_url" 2>/dev/null)" || _pull_network_error
	wget "$_tar_url" -P "$POCKER_IMAGES/$_system" 2>/dev/null || _pull_network_error
	wget -q "$_bootstrap" -P "$POCKER_IMAGES/$_system" || _pull_network_error

	echo "Downloaded rootfs for $_system"
}
