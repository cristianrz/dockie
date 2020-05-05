# shellcheck shell=sh
# Usage: dockie ls
#
# List rootfs
#
_ls() {
	[ "$#" -ne 0 ] && _print_usage "ls"

	# posix built-in way of checking if directory is empty, might fail if
	# there is a single file called '*' but you should probably not do that
	{
		echo "ROOTFS ID,IMAGE,CREATED,NAME"
		cat "$DOCKIE_GUESTS"/*/info 2>/dev/null
	} | awk -F ',' '{printf "%-15s%-15s%-25s%s\n",$1,$2,$3,$4}'
}

_ps() {
	_ls "$@"
}
