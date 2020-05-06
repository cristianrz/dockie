# shellcheck shell=sh
# Usage: dockie exec [OPTIONS] ROOTFS COMMAND [ARG...]
#
# Run a command in an existing rootfs
#
# Options:
# 	--gui      Use when a GUI is going to be run
# 	--install  Use when packages need to be installed
# 	--user     Specify Username
#
_exec_get_uid() {
	passwd="$DOCKIE_GUESTS/$2/rootfs/etc/passwd"

	[ ! -f "$passwd" ] && _log_fatal "/etc/passwd not found on rootfs"

	id="$(awk -F ':' "\$1 == \"$1\" { print \$3 }" "$passwd")"

	echo "${id:-0}"
}

_exec_is_opt() {
	case x"$1" in
	x-*) return 0 ;;
	*) return 1 ;;
	esac
}

_exec() {
	[ "$#" -lt 2 ] && _print_usage "exec"

	type="-r"
	user=
	flags="-w /"

	c="$1"
	shift
	while _exec_is_opt "$c"; do
		case x"$c" in
		x--gui | x-g) flags="$flags -b /var/lib/dbus/machine-id -b /run/shm -b /proc -b /dev" ;;
		x--user | x-u) user="$1" && shift ;;
		x--install | x-i) type='-S' ;;
		esac

		c="$1"
		shift
	done

	guest_name="$c"

	[ ! -d "$DOCKIE_GUESTS/$guest_name" ] &&
		_log_fatal "Error: No such guest: $guest_name"

	[ "$#" -eq 0 ] && _print_usage exec

	[ "$type" != "-S" ] &&
		flags="$flags -i $(_exec_get_uid "$user" "$guest_name")"

	echo
	echo "$(_strings_basename "$0"): to get the proper prompt, always" \
		"run sh/bash with the '-l' option"
	echo "You can safely ignore this message."
	echo

	PROOT="$(which proot)"

	touch "$DOCKIE_GUESTS/$guest_name/lock"
	trap 'rm "$DOCKIE_GUESTS/$guest_name/lock"' EXIT
	# shellcheck disable=SC2086
	env -i DISPLAY="$DISPLAY" "$PROOT" $flags "$type" "$DOCKIE_GUESTS/$guest_name/rootfs" "$@"
}
