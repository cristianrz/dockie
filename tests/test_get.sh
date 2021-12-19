#!/bin/sh

set -- test
. ./dockie 

testdir="$(mktemp -d)"
_get "$testdir" hello-world 

[ -f "$testdir/rootfs.tar" ]
