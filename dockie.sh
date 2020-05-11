# _bootstrap(system, id, name)
_bootstrap() {
	guest_path="$DOCKIE_GUESTS/$2"
	image_path="$DOCKIE_IMAGES/$1"
	guest_prefix="$guest_path/rootfs"

	[ ! -d "$image_path" ] && _pull "$1"

	mkdir -p "$guest_prefix"

	cd "$guest_prefix"
	# sometimes tar has errors and this is ok
	tar xf "$image_path/rootfs.tar" || true

	d="$(date '+%Y-%m-%d %H:%M:%S')"

	printf "%-11s%-15s%-21s%s\n" "$id" "$1" "$d" "$guest_name" >"$guest_path/info"

	{
		# shellcheck disable=SC2016
		printf 'export PS1="(%s) $PS1"\n' "$id"

		# not sure why PATH is not exported by default
		echo "export PATH"
	} | tee -a "$guest_prefix/etc/profile" \
		"$guest_prefix/etc/bash.bashrc" >/dev/null


	rm -f "${guest_prefix:?}"/etc/resolv.conf
	cp "${PREFIX-}"/etc/resolv.conf "$guest_prefix/etc/resolv.conf"

	printf %s\\n "$id"
}

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

	[ "$#" -eq 0 ] && _print_usage exec

	guest_path="$DOCKIE_GUESTS/$arg"
	guest_prefix="$guest_path/rootfs"

	[ ! -d "$guest_prefix" ] && _log_fatal "no such guest: $arg"

	passwd="$guest_prefix/etc/passwd"

	[ -f "$passwd" ] &&
		id="$(awk -F ':' '$1 == "'"${user-root}"'" { print $3 }' "$passwd")" &&
		guest_home="$(awk -F ':' '$1 == "'"${user-root}"'" { print $6 }' "$passwd")"

	[ -z "${flags-}" ] &&
		flags="-w "${guest_home:-/}" ${mounts-} -i ${id:-0} -r"

	touch "$guest_path/lock"

	trap 'rm $guest_path/lock' EXIT

	envs="BASH_ENV=/etc/profile ENV=/etc/profile HOME=$guest_home"

	# shellcheck disable=SC2086
	env -i $envs "$(which proot)" $flags "$guest_prefix" "$@"
}

# Usage: dockie image COMMAND
#
# Manage images
#
# Commands:
#   ls    List images
#   pull  Pull an image
#   rm    Remove one or more images" >&2
#
_image() {
	[ "$#" -eq 0 ] && ls -1 "$DOCKIE_IMAGES" && exit 0

	[ "$1" != "rm" ] && _print_usage "image"

	[ "$#" -ne 2 ] && _print_usage "image rm"

	[ ! -d "$DOCKIE_IMAGES/$2" ] &&
		_log_fatal "no such guest: $2"

	rm -rf "${DOCKIE_IMAGES:?}/$2"
}

_images() { _image "$@"; }

# Usage: dockie image rm [OPTIONS] ROOTFS
#
# Remove one or more rootfs'.
#
_log_fatal() {
	printf '\033[30;31m%s:\033[30;39m %s\n' "${0##*/}" "$*" >&2
	exit 1
}

# Usage: dockie ls
#
# List rootfs
#
_ls() {
	[ "$#" -eq 0 ] || _print_usage "ls"

	echo "ROOTFS ID  IMAGE          CREATED              NAME"
	cat "$DOCKIE_GUESTS"/*/info 2>/dev/null
}

_ps() { _ls "$@"; }

# Usage: dockie pull [OPTIONS] NAME
#
# Pull an image or a repository from a registry
#

# _pull(system)
_pull() {
	[ "$#" -ne 1 ] && _print_usage "pull"

	image_path="$DOCKIE_IMAGES/$1"

	_strings_contains "$1" ':' ||
		_log_fatal "need to specify image:version"

	rm -rf "${image_path:?}"
	mkdir -p "$image_path"

	# shellcheck disable=SC2015
	_get "$image_path" "$1" || _log_fatal "pull failed for $system"

	printf 'Downloaded rootfs for %s\n' "$1"
}

# Usage: dockie rm [OPTIONS] ROOTFS
#
# Remove an image.
#
_rm() {
	[ "$#" -eq 0 ] && _print_usage rm

	guest_path="$DOCKIE_GUESTS/$1"

	[ ! -d "$guest_path" ] && _log_fatal "no such guest '$1'"

	[ -f "$guest_path/lock" ] && _log_fatal "guest is currently in use," \
		"otherwise do 'rm $guest_path/lock'"

	rm -rf "$guest_path" || _log_fatal "Please remove any remaining files" \
		"manually."
}

# Usage: dockie run [OPTIONS] SYSTEM [COMMAND] [ARG...]
#
# Run a command in a new rootfs
#
# Options:
#     --name string    Assign a name to the guest'
#

# _run(options..., image_name)
_run() {
	[ "$#" -eq 0 ] && _print_usage "run"

	[ "$1" = "--name" ] && shift && guest_name="$1" && shift

	image_name="$1" && shift

	# need a guest name if the user did not specify any
	: "${guest_name:=$image_name}"

	id="$(cat /proc/sys/kernel/random/uuid)"
	id="${id%%-*}"

	_bootstrap "$image_name" "$id" "$guest_name"

	[ "$#" -ne 0 ] && _exec "$id" "$@"
}

# _strings_contains(string, substring)
_strings_contains() {
	case x"$1" in *"$2"*) return 0 ;; *) return 1 ;; esac
}

# Usage: dockie [OPTIONS] COMMAND [ARG...]
#
# Dockie is a wrapper around PRoot with a familiar interface
#
# Options:
# 	-d        Debug mode
# 	-h        Print usage
# 	-v        Print version information and quit
#
# Commands:
#	exec      Run a command in a root filesystem
#	image     List images
#	ls        List root filesystems
#	pull      Pull an image
#	rm        Remove one or more root filesystems
#	run       Run a command in a new root filesystem
#	search    Search the image server for images
#
# Run 'dockie COMMAND' for more information on a command.
#

VERSION="v0.6.0"

[ -z "${DOCKIE_PATH-}" ] && DOCKIE_PATH="$HOME/.local/var/lib/dockie"

DOCKIE_IMAGES="$DOCKIE_PATH/images"
mkdir -p "$DOCKIE_IMAGES"

DOCKIE_GUESTS="$DOCKIE_PATH/guests"
mkdir -p "$DOCKIE_GUESTS"

_print_usage() {
	# grab usages from comments
	_log_fatal "$(awk '
	/^# Usage: dockie '"$1"'/, $0 !~ /^#/ {
		if ( $0 ~ /^#/ ) {
			gsub(/# ?/,"")
			print
		}
	}
	' "$0")"
}

[ "$#" -eq 0 ] && _print_usage "\[O"
[ "$1" = "-v" ] && printf 'Dockie version %s\n' "$VERSION" && exit 0
[ "$1" = "-d" ] && set -x && shift

cmd="_$1" && shift
type "$cmd" >/dev/null 2>&1 || _print_usage "\[O"
"$cmd" "$@"
