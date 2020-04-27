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
# Docker-like interface for unprivileged chroots

set -eu

PREFIX="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=config.sh
. "$PREFIX/config.sh"

_usage() {
	cat <<'EOF'
"pocker ls" accepts no arguments.

Usage:  pocker ps [OPTIONS]

List rootfs
EOF
	exit 1
}

[ "$#" -ne 0 ] && _usage

[ -z "$(ls "$POCKER_GUESTS")" ] && exit 0

{
	printf 'ROOTFS ID,IMAGE,CREATED,NAME\n'
	for _guest_name in "$POCKER_GUESTS"/*; do
		_hash="$(cat "$_guest_name/id")"
		_image_name="$(cat "$_guest_name/image")"
		_date="$(cat "$_guest_name/date")"
		_guest_name="$(basename "$_guest_name")"
		printf '%s,%s,%s,%s\n' "$_hash" "$_image_name" "$_date" "$_guest_name"
	done
} | awk -F ',' '{printf "%-15s%-15s%-25s%s\n",$1,$2,$3,$4}'
