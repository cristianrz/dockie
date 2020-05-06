# shellcheck shell=sh
_bootstrap_error() {
	rm -rf "$2"
	_log_fatal "Error response: pull access denied for $1"
}

_bootstrap_hash() {
	hash="$(echo "$*$(_date)" | sha1sum)"

	# the only way I found to cut characters in POSIX using only builtins
	echo "${hash%???????????????????????????????}"
}

_bootstrap_config() {
	guest_path="$2"
	guest_name="$(_strings_basename "$guest_path")"
	guest_prefix="$guest_path/rootfs"

	id="$(_bootstrap_hash "$*")"

	echo "$id,$guest_name,$(_date),$1" >"$guest_path/info"

	{
		echo
		echo "# added by dockie"
		echo "export PS1='\033[30;34m\u@$guest_name \w \\$ \033[30;39m'"
		echo "export DISPLAY='$DISPLAY'"
	} >>"$guest_prefix/etc/profile"

	cp /etc/resolv.conf "$guest_prefix/etc/resolv.conf"

	echo "$id"
}

_bootstrap() {
	echo "Bootstrapping... This may take a few minutes depending on your" \
		"system."
	system="$1"
	guest_path="$2"
	guest_prefix="$guest_path/rootfs"

	[ ! -d "$DOCKIE_IMAGES/$system" ] && _pull "$system"

	mkdir -p "$guest_prefix"

	cd "$guest_prefix" || exit 1
	# sometimes tar has errors and this is ok
	tar xf "$DOCKIE_IMAGES/$system/rootfs.tar.xz" || true

	_bootstrap_config "$@"
}
