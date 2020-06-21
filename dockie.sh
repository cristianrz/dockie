# shellcheck shell=sh

# _init_dir(path, variable name)
_init_dir() {
	eval "$2=$1"
	mkdir -p "$1"
}

# Usage: dockie import file
#
# Import the contents from a tarball to create an image
#
_import() {
	[ "$#" -ne 1 ] && _usage "import"

	[ "$1" = "${1%.tar}" ] && _log_fatal "extension must be .tar"

	# remove dirs and extensions
	image_name="${1##*/}"
	image_name="${image_name%.*}"

	_init_dir "$DOCKIE_IMAGES/$image_name" image_path

	cp "$1" "$image_path/rootfs.tar"

	_tag_image "$image_path" "$image_name"
}

# _bootstrap(system, id, name)
_bootstrap() {
	guest_path="$DOCKIE_GUESTS/$2"
	image_path="$DOCKIE_IMAGES/$1"
	_init_dir "$guest_path/rootfs" guest_prefix

	[ ! -d "$image_path" ] && _pull "$1"

	cd "$guest_prefix" || exit 1

	# sometimes tar has errors and this is ok
	tar xf "$image_path/rootfs.tar" || true

	d="$(date '+%Y-%m-%d %H:%M:%S')"

	printf "%-14s%-20s%-21s%s\n" "$2" "$1" "$d" "$3" >"$guest_path/info"

	{
		# shellcheck disable=SC2016
		printf 'PS1="(%s)$PS1"\n' "$id"

		# if typeset exists, make PS1 immutable
		printf 'command -v typeset >/dev/null 2>&1 && typeset -r PS1\n'

		# not sure why PATH is not exported by default
		echo "export PATH PS1"

	} >>"$guest_prefix/etc/profile"

	# some distros have a symlink here, easier to just remove it
	rm -f "${guest_prefix:?}"/etc/resolv.conf
	cp "${PREFIX-}"/etc/resolv.conf "$guest_prefix/etc/resolv.conf"

	printf %s\\n "$id"
}

# Usage: dockie exec [OPTIONS] ROOTFS COMMAND [ARG...]
#
# Run a command in an existing guest
#
# Options:
# 	-g, --gui      Needed for some graphical programs to run. Will mount
#	                 /dev, /var/lib/dbus/machine-id, /run/shm and /proc
# 	-i, --install  Needed for some package managers to work. Will mount /dev,
#	                 /sys, /proc, /tmp and /run/shm
# 	-u, --user     Specify username
#       -v, --volume   mount a volume from the host to the guest, e.g -v /src:/dst
#
_exec() {
	[ "$#" -lt 1 ] && _usage "exec"

	# check if starts with -
	while arg="$1" && shift && [ "${arg#-}" != "$arg" ]; do
		case x"$arg" in
		x--gui | x-g)
			mounts="${mounts-} -b /var/lib/dbus/machine-id -b /run -b /proc -b /dev"
			;;
		x-v | x--volume) mounts="${mounts-} -b $1" && shift ;;
		x--user | x-u) user="$1" && shift ;;
		x--install | x-i)
			flags="-b /dev -b /sys -b /proc -b /run -i 0 -r"
			;;
		*) _log_fatal "invalid option '$arg'" ;;
		esac
	done

	guest_path="$DOCKIE_GUESTS/$arg"
	guest_prefix="$guest_path/rootfs"

	[ ! -d "$guest_prefix" ] && _log_fatal "no such guest: $arg"

	passwd="$guest_prefix/etc/passwd"

	if [ -f "$passwd" ]; then
		id="$(awk -F ':' '$1 == "'"${user-root}"'" { print $3 }' "$passwd")"
		guest_home="$(awk -F ':' '$1 == "'"${user-root}"'" { print $6 }' "$passwd")"
	fi

	[ -z "${flags-}" ] && flags="${mounts-} -i ${id:-0} -r"

	flags="-w ${guest_home:-/} $flags"

	# shellcheck disable=SC2015
	# it's not catastrophic if the lock can't be created
	[ ! -f "$guest_path/lock" ] && touch "$guest_path/lock" || true

	trap 'rm -f $guest_path/lock' EXIT

	envs="DISPLAY=${DISPLAY-} TERM=${TERM-} BASH_ENV=/etc/profile ENV=/etc/profile HOME=${guest_home-}"
	[ -n "${PROOT_TMP_DIR-}" ] && envs="PROOT_TMP_DIR=$PROOT_TMP_DIR $envs"

	# shellcheck disable=SC2086
	env -i $envs "$(command -v proot)" $flags "$guest_prefix" "$@"
}

_image_ls() {
	[ "$#" -ne 0 ] && _usage "image C"

	echo "REPOSITORY          CREATED               SIZE"
	cat "$DOCKIE_IMAGES"/*/info 2>/dev/null
}

# Usage: dockie image COMMAND
#
# Manage images
#
# Commands:
#   ls    List images
#   rm    Remove one or more images
#

_image() {
	[ "$#" -eq 0 ] && _image_ls "$@" && exit
	cmd="$1" && shift
	case "$cmd" in
	ls) _image_ls "$@" ;;
	rm)
		[ "$#" -ne 1 ] && _usage "image rm"
		[ ! -d "$DOCKIE_IMAGES/$1" ] && _log_fatal "no such image: $1"
		rm -rf "${DOCKIE_IMAGES:?}/$1"
		;;
	*) _usage "image C" ;;
	esac
}

_images() { _image_ls "$@"; }

# Usage: dockie image rm [OPTIONS] ROOTFS
#
# Remove a guest.
#
_log_fatal() {
	printf '\033[30;31m%s:\033[30;39m %s\n' "${0##*/}" "$*" >&2 && exit 1
}

# Usage: dockie ls
#
# List guests
#
_ls() {
	[ "$#" -ne 0 ] && _usage "ls"

	echo "ROOTFS ID     IMAGE               CREATED              NAME"
	cat "$DOCKIE_GUESTS"/*/info 2>/dev/null
}

_ps() { _ls "$@"; }

# Usage: dockie pull [OPTIONS] NAME
#
# Pull a rootfs from a repository
#

# _tag_image(path, name)
_tag_image() {
	printf '%-20s%-22s%s\n' "$2 " "$(date '+%Y-%m-%d %H:%M:%S')" \
		"$(du -h "$1/rootfs.tar" | awk '{print $1"B"}')" >"$1/info"
}

# _pull(system)
_pull() {
	[ "$#" -ne 1 ] && _usage "pull"

	! _match "$1" ':' && _log_fatal "need to specify [image]:[version]"

	if _match "$1" '/'; then
		image_path="$DOCKIE_IMAGES/${1%/*}-${1#*/}"
	else
		image_path="$DOCKIE_IMAGES/$1"
	fi

	rm -rf "${image_path:?}"
	mkdir -p "$image_path"

	# shellcheck disable=SC2015
	_get "$image_path" "$1" || _log_fatal "pull failed for $1"

	_tag_image "$image_path" "$1"
}

# Usage: dockie rm [OPTIONS] ROOTFS
#
# Remove a guest.
#
_rm() {
	[ "$#" -ne 1 ] && _usage rm

	guest_path="$DOCKIE_GUESTS/$1"

	[ ! -d "$guest_path" ] && _log_fatal "no such guest '$1'"

	[ -f "$guest_path/lock" ] && _log_fatal "guest is locked or currently" \
		"in use, otherwise do 'rm $guest_path/lock'"

	rm -rf "$guest_path" || _log_fatal "Please remove any remaining files" \
		"manually."
}

_uuid() {
	id="$(cat /proc/sys/kernel/random/uuid)"
	echo "${id##*-}"
}

# Usage: dockie run [OPTIONS] SYSTEM [COMMAND] [ARG...]
#
# Run a command in a new guest.
#
# Options:
#     -n, --name string    Assign a name to the guest'
#

# _run(options..., image_name)
_run() {
	case "x${1-}" in
	x--name | x-n) guest_name="$2" && shift 2 ;;
	"x" | x-*) _usage "run" ;;
	esac

	image_name="$1" && shift
	id="$(_uuid)"

	_bootstrap "$image_name" "$id" "${guest_name:-$image_name}" >/dev/null

	_exec "$id" "$@"
}

# _match(string, substring)
_match() { case x"$1" in *"$2"*) : ;; *) return 1 ;; esac; }

_usage() {
	# grab usages from comments
	awk '
	/^# Usage: dockie '"$1"'/, 0 {
		if ( $1 != "#" ) exit

		gsub(/# ?/,"")
		print ""$0
	}
	' "$0" && exit 1
}

# Usage: dockie [OPTIONS] COMMAND [ARG...]
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
#	import    Import the contents from a tarball to create an image
#	pull      Pull an image
#	rm        Remove one or more root filesystems
#	run       Run a command in a new root filesystem
#	search    Search the image server for images
#
# Run 'dockie COMMAND' for more information on a command.
#

set -eu

VERSION="v0.7.0"

HERE="$(
	cd "$(dirname "$0")"
	pwd
)" export HERE

: "${DOCKIE_PATH:=$HOME/.dockie}"

_init_dir "$DOCKIE_PATH/images" DOCKIE_IMAGES
_init_dir "$DOCKIE_PATH/guests" DOCKIE_GUESTS

[ "$#" -eq 0 ] && _usage "\[O"

case "x$1" in
x-v | x--version) printf 'Dockie version %s\n' "$VERSION" && exit 0 ;;
x-d | x--debug) set -x && shift ;;
x | x-*) _usage "\[O" ;;
esac

type "_$1" >/dev/null 2>&1 || _usage "\[O"

# shellcheck disable=SC2145
"_$@"
