#!/bin/sh

rm  library_hello*
trap "rm library_hello*" EXIT
./graboid hello-world
result="$(file library_hello*)"

case "$result" in
*gzip*) return 0 ;;
*) return 1 ;;
esac
