#!/bin/sh

set -- test
. ./src/dockie-pull

testdir="$(mktemp -d)"
_get "$testdir" hello-world 

[ -f "$testdir/rootfs.tar" ]
