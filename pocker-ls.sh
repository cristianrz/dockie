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
# Docker-like interface for proots

set -eu

PREFIX="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=paths.sh
. "$PREFIX/paths.sh"

_usage() {
	cat <<'EOF'
"pocker ps" accepts no arguments.
See 'pocker --help'.

Usage:  pocker ps [OPTIONS]

List rootfs
EOF
	exit 1
}

[ "$#" -ne 0 ] && _usage

[ ! -d "$POCKER_GUESTS" ] && mkdir -p "$POCKER_GUESTS"

printf 'IMAGE\tMODIFIED\t\t\tNAME\n'
for guest in $(ls -1 "$POCKER_GUESTS"); do
    date="$(stat url | grep Modify | cut -d' ' -f 2- | cut -c -19)"
    system="$(cat "$POCKER_GUESTS/$guest/etc/pocker_image")"
    printf '%s\t%s\t\t%s\n' "$guest" "$date" "$system"
done