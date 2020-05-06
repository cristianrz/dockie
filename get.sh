# shellcheck shell=sh

_get_latest() { curl -sL "$url" | awk -F"/" '/edge/ { next } /\[DIR\]/ { gsub(/<[^>]*>/,""); v=$1 } END { print v }'; }

_search() { curl -sL "$url" | awk -F"/" '/\[DIR\]/ { gsub(/<[^>]*>/,""); print $1 }'; }

_get_host_arch() {
	case "$(uname -m)" in
	x86_64) echo "amd64" ;;
	*) _log_fatal "unknown host architecture" ;;
	esac
}

_get() {
	[ "$#" -ge 2 ] && ARCH="$2" || ARCH="$(_get_host_arch)"
	url="$REMOTE/$1"
	url="$url/$(_get_latest)/$ARCH/default"
	echo "$url/$(_get_latest)/rootfs.tar.xz"
}
