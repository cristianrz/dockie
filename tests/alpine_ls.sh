#!/bin/sh

trap 'rm -rf ~/.dockie/*' EXIT
result="$(./dockie run alpine ls -l )"

case "$result" in
	*sbin*) return 0 ;;
	*) return 1 ;;
esac
