# Dockie

Dockie is a wrapper around PRoot to manage unprivileged chroots with a
familiar interface.

PRoot, and therefore Dockie, are not security features and should not be used
as such. PRoot should only be used as a "soft sandbox" where you can:

* test some other distros features,
* fake root privileges or
* build packages from source without polluting your environment

knowing that whatever gets into your PRoot will be able to get out into your
host OS.

## Dependencies

* `curl`
* `file`
* `proot`

If you want to build from source:

* `git`
* `make`

<!-- For the fakechroot version:

* `fakechroot`
* `fakeroot` -->

For the Docker version:

* `jq`

## Installation

[See "Installation" on the wiki.](https://github.com/cristianrz/dockie/wiki/Installation)

## Usage

[See "Usage" on the wiki.](https://github.com/cristianrz/dockie/wiki/Usage)

