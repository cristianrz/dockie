# Pocker

Docker-like interface for unprivileged chroots

## Dependencies

* `proot`
* `wget`
* `curl`

## Installation

```
git clone https://github.com/cristianrz/pocker.git
# optionally:
./make_shortcut "$HOME"/bin
```

## Usage

```
$ pocker --help
Illegal option --

Usage: pocker [OPTIONS] COMMAND [ARG...]

Docker-like interface for unprivileged chroot

Options:
  -D              Enable debug mode
  -h              Print usage
  -v              Print version information and quit

Commands:
    exec      Run a command in a proot
    images    List images
    ls        List rootfs
    ps        List rootfs
    pull      Pull an image
    rename    Rename a rootfs
    rm        Remove one or more rootfs
    run       Run a command in a new rootfs
    search    Search the pocker hub for images
```
