#!/bin/sh

rm  library_hello*
trap "rm library_hello*" EXIT
./build/graboid hello-world
result="$(file library_hello*)"

case "$result" in
*gzip*) exit 0 ;;
*) exit 1 ;;
esac
