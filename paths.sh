#!/bin/sh
POCKER_PREFIX="$HOME/.local"
export POCKER_IMAGES="$POCKER_PREFIX/var/lib/pocker/images"
export POCKER_GUESTS="$POCKER_PREFIX/var/lib/pocker/guests"
[ -d "$POCKER_IMAGES" ] || mkdir -p "$POCKER_IMAGES"
[ -d "$POCKER_GUESTS" ] || mkdir -p "$POCKER_GUESTS"
