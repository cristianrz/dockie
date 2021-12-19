#!/bin/sh

set -eu

arg="${1-}"

quiet(){
	case "x$arg" in
		x-v) "$@" ;;
		*) "$@" >/dev/null 2>&1 ;;
	esac
}

run_test(){
	printf '\tRunning %s...\n' "$1"
	if quiet sh "$1"; then
		echo "[✓] $1 succeeded."
	else
		echo "[X] $1 failed."
		exit 1
	fi
}

for test in ./tests/*; do
	run_test "$test"
done
