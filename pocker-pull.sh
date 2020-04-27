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
# Pulls $1
set -eu

PREFIX="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=config.sh
. "$PREFIX/config.sh"

_network_error() {
	echo "Error response: pull access denied for $_system" >&2
	rm -rf "${POCKER_IMAGES:?}/$_system"
	exit 1
}

_pull_error() {
	echo '"pocker pull" requires exactly 1 argument.

Usage:  pocker pull [OPTIONS] NAME

Pull an image or a repository from a registry' >&2
	exit 1
}

[ "$#" -ne 1 ] && _pull_error

_system="$1"

_url="$REMOTE_LIBRARY/$_system/url"
_bootstrap="$REMOTE_LIBRARY/$_system/bootstrap.sh"

rm -rf "${POCKER_IMAGES:?}/$_system"
mkdir -p "$POCKER_IMAGES/$_system"

echo "Pulling from pocker-hub/$_system"

# the url is inside the 'url' file
_tar_url="$(wget -O- "$_url" 2>/dev/null)" || _network_error
wget "$_tar_url" "$POCKER_IMAGES/$_system" 2>/dev/null || _network_error
wget -q "$_bootstrap" -P "$POCKER_IMAGES/$_system" || _network_error

echo "Downloaded rootfs for $_system"
