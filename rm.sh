# shellcheck shell=sh
_rm_usage() {
	cat <<'EOF'
"pocker rm" requires at least 1 argument.

Usage:  pocker rm [OPTIONS] ROOTFS [ROOTFS...]

Remove one or more rootfs'.
EOF
}

_rm() {
	[ "$#" -eq 0 ] && _rm_usage

	cd "$POCKER_GUESTS" || exit 1

	for fs; do
		[ ! -d "$POCKER_GUESTS/$fs" ] && echo "Error: No such container: $fs" >&2 && continue
		chmod -R +w "$fs" && rm -r "$fs" && echo "$fs"
	done
}
