#!/bin/sh

rm -rf ~/.dockie/*

result="$(./src/dockie-run alpine /bin/ls -l)"

case "$result" in
	*sbin*) return 0 ;;
	*) return 1 ;;
esac
