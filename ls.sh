# shellcheck shell=sh
# Usage: pocker ls
#
# List rootfs
#
_ls() {
	[ "$#" -ne 0 ] && _print_usage "ls"

	[ -z "$(ls "$POCKER_GUESTS")" ] && exit 0

	{
		printf 'ROOTFS ID,IMAGE,CREATED,NAME\n'
		for _guest_name in "$POCKER_GUESTS"/*; do
			_hash="$(cat "$_guest_name/id" 2>/dev/null)"
			_image_name="$(cat "$_guest_name/image" 2>/dev/null)"
			_date="$(cat "$_guest_name/date" 2>/dev/null)"
			_guest_name="$(basename "$_guest_name")"
			printf '%s,%s,%s,%s\n' "$_hash" "$_image_name" "$_date" "$_guest_name"
		done
	} | awk -F ',' '{printf "%-15s%-15s%-25s%s\n",$1,$2,$3,$4}'
}

_ps() {
	_ls "$@"
}
