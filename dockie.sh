# shellcheck shell=sh

# _init_dir(path, variable name)
_init_dir(){
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

	image_name="${1##*/}"
	image_name="${image_name%.*}"

	_initdir "$DOCKIE_IMAGES/$image_name" image_path

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

	printf "%-14s%-20s%-21s%s\n" "$id" "$1" "$d" "$3" >"$guest_path/info"

	{
		# shellcheck disable=SC2016
		printf 'export PS1="(%s) $PS1"\n' "$id"

		# not sure why PATH is not exported by default
		echo "export PATH"
	} | tee -a "$guest_prefix/etc/profile" \
		"$guest_prefix/root/.bashrc" \
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
# 	--user     Specify username
#
_exec() {
	[ "$#" -lt 2 ] && _usage "exec"

	# check if starts with -
	while arg="$1" && shift && [ "${arg#-}" != "$arg" ]; do
		case x"$arg" in
		x--gui)
			mounts="-b /var/lib/dbus/machine-id -b /run/shm -b /proc -b /dev"
			;;
		x--user) user="$1" && shift ;;
		x--install) flags="-S" ;;
		*) _log_fatal "invalid option '$arg'" ;;
		esac
	done

	[ "$#" -eq 0 ] && _usage exec

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

	# shellcheck disable=SC2086
	env -i $envs "$(which proot)" $flags "$guest_prefix" "$@"
}

_image_ls(){
	[ "$#" -eq 0 ] || _usage "image C"

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
	case "${1-}" in
	ls) _image_ls "$@" ;;
	rm)
		[ "$#" -ne 2 ] && _usage "image rm"
		[ ! -d "$DOCKIE_IMAGES/$2" ] && _log_fatal "no such image: $2"
		rm -rf "${DOCKIE_IMAGES:?}/$2"
		;;
	*) _usage "image C" ;;
	esac
}

_images() { _image_ls "$@"; }

# Usage: dockie image rm [OPTIONS] ROOTFS
#
# Remove one or more rootfs'.
#
_log_fatal() {
	printf '\033[30;31m%s:\033[30;39m %s\n' "${0##*/}" "$*" >&2 && exit 1
}

# Usage: dockie ls
#
# List rootfs
#
_ls() {
	[ "$#" -eq 0 ] || _usage "ls"

	echo "ROOTFS ID     IMAGE               CREATED              NAME"
	cat "$DOCKIE_GUESTS"/*/info 2>/dev/null
}

_ps() { _ls "$@"; }

# Usage: dockie pull [OPTIONS] NAME
#
# Pull an image or a repository from a registry
#

# _tag_image(path, name)
_tag_image(){
	printf '%-20s%-22s%s\n' "$2 " "$(date '+%Y-%m-%d %H:%M:%S')" \
		"$(du -h "$1/rootfs.tar" | awk '{print $1"B"}')" > "$1/info"
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

_uuid(){
	id="$(cat /proc/sys/kernel/random/uuid)"
	echo "${id##*-}"
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
	[ "$#" -eq 0 ] && _usage "run"

	[ "$1" = "--name" ] && guest_name="$2" && shift 2

	image_name="$1" && shift

	_bootstrap "$image_name" "$(_uuid)" "${guest_name:-$image_name}"

	[ "$#" -ne 0 ] && _exec "$id" "$@"
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

VERSION="v0.6.1"

: "${DOCKIE_PATH:=$HOME/.local/var/lib/dockie}"

_init_dir "$DOCKIE_PATH/images" DOCKIE_IMAGES
_init_dir "$DOCKIE_PATH/guests" DOCKIE_GUESTS

[ "$#" -eq 0 ] && _usage "\[O"
[ "$1" = "-v" ] && printf 'Dockie version %s\n' "$VERSION" && exit 0
[ "$1" = "-d" ] && set -x && shift

type "_$1" >/dev/null 2>&1 || _usage "\[O"

# shellcheck disable=SC2145
"_$@" 

