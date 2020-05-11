# shellcheck shell=sh

# _get(path, system, architecture)
_get() {
	TMP="$(mktemp -d)"
	trap 'rm -rf "$TMP"' EXIT

	echo "Pulling from Docker Hub..."
	docker-hub-pull "$TMP" "$2" >/dev/null || return 1

	# shellcheck disable=SC2012
	mv "$(ls -1S "$TMP"/*/layer.tar | head -n 1)" "$1/rootfs.tar.gz"

	gzip -qdv "$1/rootfs.tar.gz" >/dev/null 2>&1 || return 1
}

_search() { echo 'https://hub.docker.com/search?q=&type=image'; }
