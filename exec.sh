# shellcheck shell=sh
_exec_get_uid() {
	passwd="$POCKER_GUESTS/$1/rootfs/etc/passwd"

	[ ! -f "$passwd" ] && echo 0 && return

	awk -F ':' '$1 = '"$(whoami)"'{print $3}' "$POCKER_GUESTS/$1/rootfs/etc/passwd"
}

_exec_usage() {
	echo '"pocker exec" requires at least 2 arguments.

Usage:  pocker exec [OPTIONS] ROOTFS COMMAND [ARG...]

Run a command in an existing rootfs

Options:
    --user  Username'
	exit 1
}

_exec() {
	[ "$#" -lt 2 ] && _usage

	_user=root

	[ "$1" = "--user" ] && _user="$2" && shift 2

	_guest_name="$1" && shift

	[ ! -d "$POCKER_GUESTS/$_guest_name" ] &&
		echo "Error: No such container: $_guest_name" >&2 && exit 1

	[ "$#" -eq 0 ] && _usage

	cat <<'EOF' >&2

Tip: to get the proper prompt, always run sh/bash with the '-l' option

EOF

	env -i proot -w / -r "$POCKER_GUESTS/$_guest_name/rootfs" -i "$(_get_uid "$_user")" "$@"
}
