# shellcheck shell=sh
_log_fatal() {
	printf '%s: %s\n' "$(basename "$0")" "$*"
	exit 1
}
