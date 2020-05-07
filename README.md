# Dockie

Dockie is a wrapper around PRoot to manager unprivileged `chroot` with a
familiar interface.

PRoot, and therefore Dockie, are not security features and should not be used
as such. PRoot should only be used as a "soft sandbox" where you can:

* test some other distros features,
* fake root privileges or
* build packages from source without polluting your environment

knowing that whatever gets into your PRoot will be able to get out into your
host OS.

## Dependencies

* `git` (only if you want to download the repo)
* `proot`
* `curl`

For the Docker Hub downloader:

* `jq`

## Installation

```
$ git clone https://github.com/cristianrz/dockie.git
$ cd dockie
$ make
$ make install
```

## Usage

Get a remote root filesystem containing Alpine Linux from the
[Dockie hub](https://github.com/cristianrz/dockie-hub/tree/master/library),
set it up and chroot into it with a single command:

```
$ dockie run --name my_alpine alpine /bin/sh -l
```

now we are inside alpine, lets print something and leave:

```
root@my_alpine / # date
Tue  5 May 12:57:05 BST 2020
root@my_alpine / # exit
```

let's also get a Void Linux one:

```
$ dockie run --name my_void void /bin/bash -l
```

see which we got so far:

```
$ dockie ps
ROOTFS ID      IMAGE          CREATED                  NAME
e322828157cd   alpine         2020-04-27 19:10:00      my_alpine
b8db93b41e83   void           2020-04-27 19:11:00      my_void
```

and now delete them both:

```
$ dockie rm my_alpine my_void
```

but the images remain available locally in case you want to use them again:

```
$ dockie images
void
alpine
```

you can also delete them

```
$ dockie image rm void
$ dockie images
alpine
```

Also, all the most used Docker commands are available:

| **Command** | **Description**                        |
| ---         | ---                                    |
| `exec`      | Run a command in a root filesystem     |
| `images`    | List images                            |
| `ls`        | List root filesystems                  |
| `pull`      | Pull an image                          |
| `rm`        | Remove one or more root filesystems    |
| `run`       | Run a command in a new root filesystem |
| `search`    | Search the image server                |

For more information on a command:

```
$ dockie COMMAND
```
