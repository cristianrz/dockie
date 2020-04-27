#!/usr/bin/env sh
#
# BSD 3-Clause License
#
# Copyright (c) 2020, Cristian Ariza
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# Docker-like interface for user-space chroots

set -eu

PREFIX="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=paths.sh
. "$PREFIX/paths.sh"

[ ! -d "$POCKER_GUESTS" ] && mkdir -p "$POCKER_GUESTS"

_log_fatal() {
	printf '%s: %s\n' "$(basename "$0")" "$*"
	exit 1
}

_get_uid() {
	passwd="$POCKER_GUESTS/$1/rootfs/etc/passwd"

	[ ! -f "$passwd" ] && echo 0 && return

	awk -F ':' '$1 = '"$(whoami)"'{print $3}' "$POCKER_GUESTS/$1/rootfs/etc/passwd"
}

_usage() {
	echo '"pocker exec" requires at least 2 arguments.

Usage:  pocker exec [OPTIONS] ROOTFS COMMAND [ARG...]

Run a command in an existing rootfs

Options:
    --user  Username'
	exit 1
}

[ "$#" -lt 2 ] && _usage

_user=root

[ "$1" = "--user" ] && shift && _user="$1" && shift

_guest_name="$1" && shift

[ ! -d "$POCKER_GUESTS/$_guest_name" ] &&
	echo "Error: No such container: $_guest_name" >&2 && exit 1

[ "$#" -eq 0 ] && _usage

cd /

echo
echo "Tip: to get the proper prompt, always run sh/bash with the '-l'" >&2
echo "option" >&2
echo
env -i proot -r "$POCKER_GUESTS/$_guest_name/rootfs" -i "$(_get_uid "$_user")" "$@"
