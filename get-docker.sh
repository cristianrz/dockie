# shellcheck shell=sh

# _get(path, system, architecture)
_get() {
	TMP="$(mktemp -d)"
	trap 'rm -rf "$TMP"' EXIT

	docker-hub-pull "$TMP" "$2:latest" >/dev/null || exit 1

	# shellcheck disable=SC2012
	mv "$(ls -1S "$TMP"/*/layer.tar | head -n 1)" "$1/rootfs.tar.gz"

	gzip -dv "$1/rootfs.tar.gz"
}

_search() {
	echo "There is no built-in search for the docker hub, but you can" \
		"visit"
	printf '\n\thttps://hub.docker.com/search?q=&type=image\n\n'
	echo "for a list of the available images"
}
