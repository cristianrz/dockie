# shellcheck shell=sh
_bootstrap_error() {
	rm -rf "$2"
	_log_fatal "Error response: pull access denied for $1"
}

_bootstrap_hash(){
	printf '%s%s\n' "$*" "$(date)" | sha1sum | cut -c -12
}

_bootstrap_config(){
	date '+%Y-%m-%d %H:%M:%S' >"$2/date"

	_id="$(_bootstrap_hash "$*")"
	printf '%s\n' "$_id" >"$2/id"

	printf '%s\n' "$1" >"$2/image"
	{
		printf 'export PS1='\''\u@%s \w \$ '\' "$(basename "$2")"
		echo 'export DISPLAY=":0.0"'
	} >>etc/profile

	rm -f etc/resolv.conf
	cat /etc/resolv.conf >etc/resolv.conf
}

_bootstrap() {
	[ ! -d "$POCKER_IMAGES/$1" ] && _pull "$1"

	mkdir -p "$2"/rootfs

	cd "$2/rootfs" || exit 1

	sh "$POCKER_IMAGES/$1/bootstrap" || true
	_bootstrap_config "$@"
	printf '%s\n' "$_id"
}
