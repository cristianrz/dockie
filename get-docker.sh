# shellcheck shell=sh
_get(){
	TMP="$(mktemp -d)"
	trap 'rm -rf "$TMP"' EXIT

	docker-hub-pull "$TMP" "$1:latest" >/dev/null

	# shellcheck disable=SC2012
	mv "$(ls -1S "$TMP"/*/layer.tar | head -n 1)" rootfs.tar.gz

	gzip -dv rootfs.tar.gz
}


_search(){
	echo "There is no built-in search for the docker hub, but you can" \
		"visit"
	printf '\n\thttps://hub.docker.com/search?q=&type=image\n\n'
	echo "for a list of the available images"
}
