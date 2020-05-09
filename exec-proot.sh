# shellcheck shell=sh

# Usage: dockie exec [OPTIONS] ROOTFS COMMAND [ARG...]
#
# Run a command in an existing rootfs
#
# Options:
# 	--gui      Use when a GUI is going to be run, mounts
#	               /var/lib/dbus/machine-id, /run/shm, /proc and /dev
# 	--install  Needed for most of package managers to work
# 	--user      Specify username
#
_exec() {
	[ "$#" -lt 2 ] && _print_usage "exec"

	arg="$1"
	shift

	# check if starts with -
	while [ "${arg#-}" != "$arg" ]; do
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

	[ "$#" -eq 0 ] && _print_usage exec

	[ ! -d "$guest_prefix" ] && _log_fatal "no such guest: $arg"

	passwd="$guest_prefix/etc/passwd"

	[ -f "$passwd" ] &&
		id="$(awk -F ':' '$1 == '"${user-root}"' { print $3 }' "$passwd")"

	[ -z "${flags-}" ] &&
		flags="${mounts-} -i ${id:-0} -r"

	touch "$guest_path/lock"

	trap 'rm $guest_path/lock' EXIT

	# shellcheck disable=SC2086
	env -i DISPLAY="${DISPLAY-}" "$(which proot)" -w / $flags \
		"$guest_prefix" "$@"

}

