#!/bin/sh

set -eu

pass=0
fail=0

arg="${1-}"

# runs a command without outputting anything to terminal
quiet(){
	case "x$arg" in
		x-v) "$@" ;;
		*) "$@" >/dev/null 2>&1 ;;
	esac
}

run_test(){
	quiet printf '\tRunning %s...\n' "$1"
	if quiet sh "$1"; then
		printf '\e[42m\e[30m PASS \e[39m\e[49m %s\n' "$1"
		: "$((pass+=1))"
	else
		printf '\e[41m\e[30m FAIL \e[39m\e[49m %s\n' "$1"
		: "$((fail+=1))"
	fi
}

for test in ./test/*; do
	run_test "$test"
done

printf '\nRan %d tests, %d passed, %d failed (%d%% pass).\n' "$((pass+fail))" "$((pass))" "$((fail))" "$((100*pass/(pass+fail)))"
