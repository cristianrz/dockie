<p align="center"><img src="docs/whale_small.png" width="220px"></p>

# Dockie

**Website:** https://dockie.org

**Get started:** https://github.com/cristianrz/dockie/wiki

**FAQ:** https://github.com/cristianrz/dockie/wiki/FAQ

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

* `make`

For the Docker version:

* `bash`
* `go` / `golang`
* `jq`

There is an experimental branch called "unshare" which does not need PRoot, but a Linux kernel that supports namespaces. If you are not able to install PRoot you should check that out. 

## Installation

[See "Installation" on the wiki.](https://github.com/cristianrz/dockie/wiki#installation)

## Usage

[See "Usage" on the wiki.](https://github.com/cristianrz/dockie/wiki#usage)

