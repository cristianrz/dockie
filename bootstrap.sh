# shellcheck shell=sh

# _bootstrap_config(system, id, name)
_bootstrap_config() {
	guest_name="$3"

	guest_path="$DOCKIE_GUESTS/$2"
	guest_prefix="$guest_path/rootfs"


	echo "$id,$1,$(_date),$guest_name" > "$guest_path/info"
	echo "$id"

	{
		echo
		echo "# added by dockie"
		[ -n "${DISPLAY-}" ] && echo "export DISPLAY='$DISPLAY'"
		# not sure why PATH is not exported by default
		echo "export PATH"
		echo "export PS1='\033[30;34m\u@$guest_name \w \\$ \033[30;39m'"
	} >>"$guest_prefix/etc/profile"

	rm -f "${guest_prefix:?}"/etc/resolv.conf
	cp /etc/resolv.conf "$guest_prefix/etc/resolv.conf"

}

# _bootstrap(system, id, name)
_bootstrap() {
	# echo "Bootstrapping... This may take a few minutes depending on your" \
	# "system."
	system="$1"
	guest_path="$DOCKIE_GUESTS/$2"
	guest_prefix="$guest_path/rootfs"

	[ ! -d "$DOCKIE_IMAGES/$system" ] && _pull "$system"

	mkdir -p "$guest_prefix"

	# sometimes tar has errors and this is ok
	_tar_c "$guest_prefix" xf "$DOCKIE_IMAGES/$system/rootfs.tar" || true

	_bootstrap_config "$@"
}
