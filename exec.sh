# shellcheck shell=sh

# _exec_get_uid(user, root_path)
_exec_get_uid() {
	passwd="$2/rootfs/etc/passwd"

	[ ! -f "$passwd" ] && echo 0 && return

	id="$(awk -F ':' "\$1 == \"$1\" { print \$3 }" "$passwd")"

	echo "${id:-0}"
}

_exec_is_opt() {
	case x"$1" in
	x-*) return 0 ;;
	*) return 1 ;;
	esac
}

# Usage: dockie exec [OPTIONS] ROOTFS COMMAND [ARG...]
#
# Run a command in an existing rootfs
#
# Options:
# 	--gui      Use when a GUI is going to be run, mounts
#	               /var/lib/dbus/machine-id, /run/shm, /proc and /dev
# 	--install  Needed for most of package managers to work
# 	-user      Specify username
#
_exec() {
	[ "$#" -lt 2 ] && _print_usage "exec"

	flags="-r"
	mounts=
	user=root

	arg="$1"
	shift
	while _exec_is_opt "$arg"; do
		case x"$arg" in
		x--gui)
			mounts="-b /var/lib/dbus/machine-id -b /run/shm -b /proc -b /dev"
			;;
		x--user) user="$1" && shift ;;
		x--install) flags="-S" ;;
		*) _log_fatal "invalid option '$arg'" ;;
		esac

		arg="$1"
		shift
	done

	guest_path="$DOCKIE_GUESTS/$arg"
	guest_prefix="$guest_path/rootfs"

	[ ! -d "$guest_prefix" ] && _log_fatal "no such guest: $arg"
	[ "$#" -eq 0 ] && _print_usage exec

	id="$(_exec_get_uid "$user" "$guest_prefix")"

	[ "$flags" = "-r" ] &&
		flags="$mounts -i $id $flags"

	touch "$guest_path/lock"

	trap 'rm "$guest_path/lock"' EXIT

	echo
	echo "$(_strings_basename "$0"): to get the proper prompt, always" \
		"run sh/bash with the '-l' option"
	echo "You can safely ignore this message."
	echo

	PROOT="$(which proot)"

	# shellcheck disable=SC2086
	env -i DISPLAY="$DISPLAY" "$PROOT" -w / $flags "$guest_prefix" "$@"
}
