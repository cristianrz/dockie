# Pocker

Docker-like interface for unprivileged chroots

## Dependencies

* `proot`
* `wget`

## Installation

```
$ git clone https://github.com/cristianrz/pocker.git
$ cd pocker
$ make
$ make install
```

## Usage

Get a remote root filesystem [from the pocker hub](https://github.com/cristianrz/pocker-hub/tree/master/library), set it up and chroot into it:

```
$ pocker run --name my_alpine alpine /bin/sh -l
```

also get a Void Linux one:

```
$ pocker run --name my_void void /bin/bash -l
```

see which ones you got:

```
$ pocker ps
ROOTFS ID      IMAGE          CREATED                  NAME
e322828157cd   alpine         2020-04-27 19:10:00      my_alpine
b8db93b41e83   void           2020-04-27 19:11:00      my_void
```

and now delete them both:

```
$ pocker rm my_alpine my_void
```

but the images remain available locally in case you want to use them again:

```
$ pocker images
void
alpine
```

you can also delete them

```
$ pocker image rm void
$ pocker images
alpine
```

Also, all the most used Docker commands are available:

| **Command** | **Description**                        |
| ---         | ---                                    |
| `exec`      | Run a command in a root filesystem     |
| `images`    | List images                            |
| `ls`        | List root filesystems                  |
| `pull`      | Pull an image                          |
| `rename`    | Rename a root filesystem               |
| `rm`        | Remove one or more root filesystems    |
| `run`       | Run a command in a new root filesystem |
| `search`    | Search the pocker hub for images       |

For more information on a command:

```
$ pocker COMMAND
```
