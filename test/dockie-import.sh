#!/bin/sh

set -eu

testhere="$(pwd)"

testdir="$(mktemp -d)"
cd "$testdir"

"$testhere/build/graboid" hello-world 

tar xzf ./*gz
mv ./*tar hello-world.tar

cd "$testhere"

./src/dockie-import "$testdir"/*tar

out="$(file ~/.dockie/images/hello-world/rootfs.tar)"

case "$out" in
*gzip*) exit 0 ;;
*) exit 1 ;;
esac
