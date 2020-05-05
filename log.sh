# shellcheck shell=sh
_log_fatal() {
	echo "$(_strings_basename "$0"): $*"
	exit 1
}
