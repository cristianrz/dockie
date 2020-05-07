# shellcheck shell=sh

_search() {
	_log_fatal "no built-in search for local pulls"
}

# _get(path, system, architecture)
_get() {
	mv "$2" "$path"
}
