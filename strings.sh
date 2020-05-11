# shellcheck shell=sh

# _strings_contains(string, substring)
_strings_contains() {
	case x"$1" in *"$2"*) return 0 ;; *) return 1 ;; esac
}
