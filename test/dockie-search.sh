#!/bin/sh
 
set -- test

result="$(./src/dockie-search hello-world)"


case "$result" in
	*"search?q=hello-world"*) return 0 ;;
	*)
		echo "\"${result}\""
		return 1
		;;
esac
