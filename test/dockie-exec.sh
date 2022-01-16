#!/bin/sh

set -eu

id="$(./src/dockie-run -d alpine 2>/dev/null || true)"

case "${#id}" in
12) : ;;
*) echo "id: '$id'?"; exit 1 ;;
esac

out="$(dockie exec "$id" ls 2>&1)"

case "$out" in
*sbin*) exit 0 ;;
*) echo "$out"; exit 1 ;;
esac

