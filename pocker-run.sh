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
	echo '"pocker run" requires at least 1 argument.
See "pocker --help".

Usage:  pocker run [OPTIONS] SYSTEM [COMMAND] [ARG...]

Run a command in a new rootfs

Options:
    --name string    Assign a name to the container'
	exit 1
}

_error_existing() {
	echo "pocker: Error response: Conflict. The container name '/$1' is already in use. You have to"
	echo "remove (or rename) that container to be able to reuse that name."
	echo "See 'pocker --help'."
	exit 1
}

# Run needs at least one argument
[ "$#" -eq 0 ] && _usage

[ "$1" = "--name" ] && shift && _guest_name="$1" && shift

_system_name="$1" && shift

# Need a guest name if the user did not specify any
: "${_guest_name=$_system_name}"

[ -d "$POCKER_GUESTS/$_guest_name" ] && _error_existing "$_guest_name"

sh "$PREFIX"/pocker-bootstrap.sh "$_system_name" "$POCKER_GUESTS/$_guest_name"

[ "$#" -eq 0 ] && return 0

sh "$PREFIX/pocker-exec.sh" "$_guest_name" "$@"
