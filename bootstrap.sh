# shellcheck shell=sh
_bootstrap_config() {
	guest_path="$2"
	guest_name="$(_strings_basename "$guest_path")"
	guest_prefix="$guest_path/rootfs"

	# generate uuid
	id="$(cat /proc/sys/kernel/random/uuid)"
	id="${id%%-*}"

	echo "$id,$guest_name,$(_date),$1" >"$guest_path/info"

	{
		echo
		echo "# added by dockie"
		echo "export DISPLAY='$DISPLAY'"
		# not sure why PATH is not exported by default
		echo "export PATH"
		echo "export PS1='\033[30;34m\u@$guest_name \w \\$ \033[30;39m'"
	} >>"$guest_prefix/etc/profile"

	rm -f "$guest_prefix"/etc/resolv.conf
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
	tar xf "$DOCKIE_IMAGES/$system/rootfs.tar" || true

	_bootstrap_config "$@"
}
