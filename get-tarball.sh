# shellcheck shell=sh

# Usage: dockie import file
# 
# Import the contents from a tarball to create a filesystem image
#
_import() {
	case "$2" in
	*.tar)
		image_name="${1##*/}"
		image_name="${image_name%.*}"
		image_path="$DOCKIE_IMAGES/$image_name"

		mkdir -p "$image_path"
		cp "$1" "$image_path/rootfs.tar"

		d="$(date '+%Y-%m-%d %H:%M:%S')"
		s="$(du -h "$image_path/rootfs.tar" | awk '{print $1}')"
		echo "$ORIGIN,$(_uuid),$d,$s" > "$image_path/info"
		;;
	*) _log_fatal "only *.tar.xz is supported" ;;
	esac
}

