# shellcheck shell=sh

REMOTE="https://us.images.linuxcontainers.org/images"

_get_latest() { curl -sL "$url" | awk -F"/" '/edge/ { next } /\[DIR\]/ { gsub(/<[^>]*>/,""); v=$1 } END { print v }'; }

# Usage: dockie search [OPTIONS] TERM
#
# Search the LXC image server for images
#
_search() {
	[ "$#" -gt 1 ] && _print_usage "search"
	curl -sL "$REMOTE" | awk -F"/" '/\[DIR\]/ && /'"${1-}"'/ { gsub(/<[^>]*>/,""); print $1 }'
}

# _get_host_arch() {
# 	case "$(uname -m)" in
# 	x86_64) echo "amd64" ;;
# 	*) _log_fatal "unknown host architecture" ;;
# 	esac
# }

# _get system 
_get() {
	ARCH="amd64"

	[ "$#" -gt 1 ] && ARCH="$2"
	
	url="$REMOTE/$1"
	url="$url/$(_get_latest)/$ARCH/default"
	wget "$url/$(_get_latest)/rootfs.tar.xz"
	tar xf rootfs.tar.xz
}
