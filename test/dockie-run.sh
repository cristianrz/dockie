#!/bin/sh

rm -rf ~/.dockie/*

result="$(./src/dockie-run arm64v8/alpine /bin/ls -l)"

case "$result" in
	*sbin*) exit 0 ;;
	*) exit 1 ;;
esac
