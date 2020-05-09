# shellcheck shell=sh

# _bootstrap_config(system, id, name)
_bootstrap_config() {
	guest_name="$3"
	guest_path="$DOCKIE_GUESTS/$2"
	guest_prefix="$guest_path/rootfs"

	echo "$id,$1,$(date '+%Y-%m-%d %H:%M:%S'),$guest_name" >"$guest_path/info"
	echo "$id"

	{
		[ -n "${DISPLAY-}" ] && echo "export DISPLAY='$DISPLAY'"
		# not sure why PATH is not exported by default
		echo "export PATH"
	} >>"$guest_prefix/etc/profile"

	printf 'export PS1="(%s) $PS1"' "$id" |
		tee -a "$guest_prefix/etc/profile" \
			>>"$guest_prefix/root/.bashrc"

	rm -f "${guest_prefix:?}"/etc/resolv.conf
	cp "${PREFIX-}"/etc/resolv.conf "$guest_prefix/etc/resolv.conf"

}

# _bootstrap(system, id, name)
_bootstrap() {
	guest_path="$DOCKIE_GUESTS/$2"
	image_path="$DOCKIE_IMAGES/$1"
	guest_prefix="$guest_path/rootfs"

	[ ! -d "$image_path" ] && _pull "$2"

	mkdir -p "$guest_prefix"

	cd "$guest_prefix"
	# sometimes tar has errors and this is ok
	tar xf "$image_path/rootfs.tar" || true

	_bootstrap_config "$@"
}
