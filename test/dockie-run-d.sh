#!/bin/sh

out="$(sh ./src/dockie-run -d alpine 2>/dev/null)"

chars="${#out}"


case "$chars" in
12) exit 0 ;;
*)
	echo "$out"
	exit 1 ;;
esac
