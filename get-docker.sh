# shellcheck shell=sh
# _get(path, system, architecture)
_get() {
	TMP="$(mktemp -d)"
	trap 'rm -rf "$TMP"' EXIT

	echo "Pulling from Docker Hub..."
	bash "$HERE/../lib/dockie/docker-hub-pull" "$TMP" "$2" >/dev/null || return 1

	FS="$(mktemp -d)"
	trap 'rm -rf $FS' EXIT
	cd "$FS" || exit 1

	for tar in "$TMP"/*/layer.tar; do
		tar xzf "$tar"
	done

	tar cf "$1/rootfs.tar" .
}

_search() { echo 'https://hub.docker.com/search?q=&type=image'; }
