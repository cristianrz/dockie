#!/bin/sh

# Base directory where pocker is installed
_POCKER_PREFIX="$HOME/.local"

# Contains the images
export POCKER_IMAGES="$_POCKER_PREFIX/var/lib/pocker/images"
[ -d "$POCKER_IMAGES" ] || mkdir -p "$POCKER_IMAGES"

# Contains the guests
export POCKER_GUESTS="$_POCKER_PREFIX/var/lib/pocker/guests"
[ -d "$POCKER_GUESTS" ] || mkdir -p "$POCKER_GUESTS"

# Where to read the libraries from
export POCKER_LIB="$_POCKER_PREFIX/lib/pocker"

export REMOTE_LIBRARY="https://cristianrz.github.io/pocker-hub/library"
