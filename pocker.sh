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

IMAGES="$HOME"/.local/lib/pocker/images
PROOTS="$HOME"/.local/lib/pocker/proots

_extract() {
	case "$1" in
	*.tbz2 | *.tar.bz2) tar fjvx "$@" ;;
	*.tar | *.tar.xz) tar fvx "$@" ;;
	*.tgz | *.tar.gz) tar fvxz "$@" ;;
	*.7z) 7za x "$@" ;;
	*.Z) uncompress "$@" ;;
	*.bz2) bunzip2 "$@" ;;
	*.gz) gunzip "$@" ;;
	*.rar) unrar e "$@" ;;
	*.zip) unzip "$@" ;;
	*) die "'$*' cannot be extracted" ;;
	esac
}

_log_error() {
	printf '%s: %s\n' "$(basename "$0")" "$*"
}

_log_fatal() {
	_log_error "$@"
	exit 1
}

_rm() {
	_id="$1"
	shift

	if [ -z "$PROOTS" ]; then
		_log_fatal "PROOTS is empty"
	elif [ -z "$_id" ]; then
		_log_fatal "no name given"
	fi

	rm -r "${PROOTS:?}/$_id"
}

_get_uid() {
	passwd="$PROOTS/$_name/etc/passwd"

	if [ -f "$passwd" ]; then
		grep -E "^$_user:" "$PROOTS/$_name/etc/passwd" | cut -d':' -f 3
	else
		echo 0
	fi
}

_pull(){

}


_exec() {
	_user=root
	cd "$HOME" || exit 1

	if [ "$#" -eq 0 ]; then
		_log_fatal '"pocker exec" requires at least 1 argument.
See "pocker --help".

Usage:  pocker run [OPTIONS] IMAGE [COMMAND] [ARG...]

Run a command in a new proot'
	fi

	[ "$1" = "--user" ] && shift && _user="$1" && shift
	_name="$1" && shift

	if [ "$#" -eq 0 ]; then
		_log_fatal '"pocker exec" requires at least 2 arguments.
See "pocker --help".

Usage:  pocker exec [OPTIONS] proot COMMAND [ARG...]

Run a command in a running proot'
	fi

	proot -r "$PROOTS/$_name" -i "$(_get_uid "$_user")" "$@"
}

_run() {
	_name=

	[ "$1" = "--name" ] && _name="$2" && shift && shift

	_system="$1" && shift

	if [ "$#" -eq 0 ]; then
		_log_fatal '"pocker run" requires at least 1 argument.
See "pocker --help".

Usage:  pocker run [OPTIONS] IMAGE [COMMAND] [ARG...]

Run a command in a new proot'
	fi

	[ ! -f "$BOOTSTRAP/$_system" ] && _log_fatal "script for $_system is not available"
	[ -z "$_name" ] && _name="$_system"
	[ -z "$PROOTS" ] && _log_fatal "PROOTS environment variable is undefined"
	[ -d "$PROOTS/$_system" ] && _log_fatal "$_system already exists"

	_url="$(cat "$BOOTSTRAP/$_system")"
	printf 'Pulling from %s...\n' "$_url"
	cd "$PROOTS"
	mkdir "$_system"
	cd "$_system"
	wget "$_url"
	_extract ./*
	mkdir -p home/"$(whoami)"

	printf '%s: Pull complete.\n' "$_id"

	[ "$#" -eq 0 ] && return 0

	cd "$HOME"
	proot -r "$PROOTS"/"$_system"
}

# _ps()
# Lists the installed proots
_ps() {
	find "$PROOTS" -maxdepth 1 -type d -exec basename {} \; | sed 1d
}

# _version()
# Show version and exit
_version() {
	echo pocker version 0.0.1
	exit 0
}

# _help()
# Show help and exit
_help() {
	cat <<'EOF'

Usage: pocker [OPTIONS] COMMAND [ARG...]
       pocker [ -h | -v ]

Docker-like interface for proot and debootstrap

Options:
  -D              Enable debug mode
  -h              Print usage
  -v              Print version information and quit

Commands:
    exec      Run a command in a proot
    ps        List proots
    rename    Rename a proot
    rm        Remove one or more proots
    run       Run a command in a new proot

EOF
	exit 1
}

while getopts "Dv" _c; do
	case "$_c" in
	D) set -x ;;
	v) _version ;;
	*) _help ;;
	esac
done
shift $((OPTIND - 1))

[ "$#" -eq 0 ] && _help

_cmd="$1" && shift

case "$_cmd" in
run | rm | ps | exec) _"$_cmd" "$@" ;;
*) _help ;;
esac

:
