# shellcheck shell=sh
_log_fatal() {
	printf '\033[30;31m%s:\033[30;39m %s\n' "$(basename "$0")" "$*" >&2
	exit 1
}
