#!/bin/sh

set -eu

testhere="$(pwd)"

trap 'rm -rf ~/.dockie' EXIT

testdir="$(mktemp -d)"
cd "$testdir"

"$testhere"/graboid hello-world >/dev/null 2>&1

tar xzf *gz
mv *tar hello-world.tar

cd "$testhere"

./dockie import "$testdir"/*tar

case "$(./dockie image ls)" in
	*4.0KB*) return 0 ;;
	*) return 1 ;;
esac
