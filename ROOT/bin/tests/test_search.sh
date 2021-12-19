#!/bin/sh
 
set -- test
. ./dockie 

result="$(_search hello-world)"

echo "x${result}x"

case "$result" in
	*"search?q=hello-world"*) return 0 ;;
	*) return 1 ;;
esac
