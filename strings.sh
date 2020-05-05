# shellcheck shell=sh
_strings_basename() {
	dir=${1%${1##*[!/]}}
	dir=${dir##*/}
	printf '%s\n' "${dir:-/}"
}
