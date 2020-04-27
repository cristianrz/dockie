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
pocker run --name my_alpine alpine /bin/sh -l
```

As well as all the most used Docker commands:

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
