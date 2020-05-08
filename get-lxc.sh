# shellcheck shell=sh

REMOTE="https://us.images.linuxcontainers.org/images"

_get_latest() {
	curl -sL "$url" | awk -F"/" '
		/\[DIR\]/ {
			gsub(/<[^>]*>/,"")
			last = $1
		}
		
		END { print last }
		'
}

# Usage: dockie search [OPTIONS] TERM
#
# Search the LXC image server for images
#
_search() {
	[ "$#" -gt 1 ] && _print_usage "search"
	curl -sL "$REMOTE" | awk -F"/" '
		/\[DIR\]/ && /'"${1-}"'/ {
			gsub(/<[^>]*>/,"")
			print $1
		}'
}

# _get_host_arch() {
# 	case "$(uname -m)" in
# 	x86_64) echo "amd64" ;;
# 	*) _log_fatal "unknown host architecture" ;;
# 	esac
# }

# _get(path, system, architecture)
_get() {
	ARCH="amd64"

	[ "$#" -gt 2 ] && ARCH="$3"

	case "$2" in
	*:*) : ;;
	*) _log_fatal "for LXC pulls, need to specify 'system:version'" ;;
	esac

	version="${2#*:}"
	system="${2%:*}"

	url="$REMOTE/$system/$version"
	url="$url/$ARCH/default"
	curl --progress-bar "$url/$(_get_latest)/rootfs.tar.xz" >"$1/rootfs.tar.xz"

	case "$(file "$1/rootfs.tar.xz")" in
	*HTML*) _log_fatal "can't find remote image '$2'" ;;
	esac

	xz -d "$1/rootfs.tar.xz"
}
