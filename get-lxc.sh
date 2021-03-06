# shellcheck shell=sh

REMOTE="https://images.linuxcontainers.org/images"

_get_latest() {
	curl -sL "$url" | awk -F"/" '
		/\[DIR\]/ { gsub(/<[^>]*>/,""); last = $1; }
		
		END { print last }'
}

# Usage: dockie search [OPTIONS] TERM
#
# Search the LXC image server for images
#
_search() { printf %s\\n "$REMOTE"; }

# _get(path, system, architecture)
_get() {
	_match "$2" ':' ||
		_log_fatal "need to specify 'system:version'"

	version="${2#*:}"
	system="${2%:*}"

	url="$REMOTE/$system/$version"
	url="$url/${DOCKIE_ARCH-amd64}/default"

	curl -L --progress-bar "$url/$(_get_latest)/rootfs.tar.xz" \
		>"$1/rootfs.tar.xz"

	_match "$(file "$1/rootfs.tar.xz")" "HTML" &&
		_log_fatal "could not find remote image '$2'"

	xz -d "$1/rootfs.tar.xz"
}
