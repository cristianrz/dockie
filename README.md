<p align="center"><img src="docs/whale_small.png" width="220px"></p>

# Dockie

**Website:** https://dockie.org

**Get started:** https://github.com/cristianrz/dockie/wiki

**FAQ:** https://github.com/cristianrz/dockie/wiki/FAQ

Dockie is a wrapper around PRoot and Graboid to manage unprivileged chroots
with a familiar interface.

Dockie can pull and run Docker images with:

* no root
* no daemons
* user namespaces disabled
* only downloading an AppImage file

PRoot, and therefore Dockie, are not security features and should not be used
as such. PRoot should only be used as a "soft sandbox" where you can:

* test some other distros features,
* fake root privileges
* build packages from source without polluting your environment
* as a dev environment to keep your main system clean

knowing that whatever gets into your PRoot will be able to get out into your
host OS. If you really want isolation you should run Dockie
[inside a VM](https://github.com/cristianrz/dockie/wiki/Isolation).

## Dependencies

* `curl`
* `file`

## Installation

[See "Installation" on the wiki.](https://github.com/cristianrz/dockie/wiki#installation)

## Usage

[See "Usage" on the wiki.](https://github.com/cristianrz/dockie/wiki#usage)

