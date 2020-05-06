# shellcheck shell=sh
# Usage: dockie ls
#
# List rootfs
#
_ls() {
	[ "$#" ] || _print_usage "ls"

	{
		echo "ROOTFS ID,IMAGE,CREATED,NAME"
		cat "$DOCKIE_GUESTS"/*/info 2>/dev/null
	} | awk -F ',' '{printf "%-15s%-15s%-25s%s\n",$1,$2,$3,$4}'
}

_ps() {
	_ls "$@"
}
