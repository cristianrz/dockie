<p align="center"><img src="docs/whale_small.png" width="220px"></p>

# Dockie

* **Installation**: https://github.com/cristianrz/dockie/#installation
* **Usage**: https://github.com/cristianrz/dockie/#usage
* **FAQ:** https://github.com/cristianrz/dockie/wiki/FAQ

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

Also, it allows you to have user environments whilst keeping user namespaces
disabled and therefore reducing your attack surface.

## Dependencies

* `curl`
* `file`

## Installation

There are two installation methods:

* [AppImage](https://github.com/cristianrz/dockie/#appimage-only-x86_64): the recommended installation method if you have
    * a 64 bit processor (which you are most likely) and
    * glibc (in contrast with, for example, musl).

It embeds PRoot inside the image. If the AppImage does not work for you or you already have PRoot, it's probably better if you use the method below.

* [Standalone Dockie](https://github.com/cristianrz/dockie/#no-appimage): if you are using Android, a 32-bit processor or any other obscure device/OS, or you don't want to embed PRoot inside Dockie.

## AppImage (only x86_64)

Grab the latest AppImage from [the releases page](https://github.com/cristianrz/dockie/releases).

Open a terminal and from your Downloads directory give the AppImage executable rights:

```
$ cd Downloads
$ chmod a+x ./dockie-x86_64.AppImage
```

Then, if you have root privileges:

```
$ sudo cp ./dockie-x86_64.AppImage /usr/local/bin/dockie
```

or, if you don't have root privileges and `$HOME/bin` is inside your `PATH` variable:

```
$ cp ./dockie-x86_64.AppImage "$HOME/bin/dockie"
```

or use it directly with

```
$ ./dockie-x86_64.AppImage
```

### Man page

If you want to have the man page available, you can do it with

```
# curl https://raw.githubusercontent.com/cristianrz/dockie/master/dockie.1 \
    >/usr/local/share/man/man1/dockie.1
```

## Build AppImage from source

```
$ git clone https://github.com/cristianrz/dockie.git
$ cd dockie
$ sh build.sh
```

Now you can 

```
# cp ./dockie-x86_64.AppImage /usr/local/bin/dockie
```

or, if you don't have root privileges

```
$ cp ./dockie-x86_64.AppImage "$HOME/bin/dockie"
```

or use it directly with

```
$ ./dockie-x86_64.AppImage
```

## No AppImage

After pulling the Dockie repo, `./src` contains all the shell scripts that Dockie uses, if you copy all of these to your PATH you're up and running. In this case you will have to manually download and install PRoot and Graboid.

## Usage

## Main commands

Get a remote root filesystem containing Alpine Linux
set it up and chroot into it with a single command:

```
$ dockie run --name my_alpine alpine:3.11 /bin/sh -l
(bdf6d5c8bd01) localhost:~#
```

From the previous command, the target image has two parts, `alpine` and `3.11`. The first is the name of the distro. `3.11` is the tag of the image, if you [click on the respective image](https://uk.images.linuxcontainers.org/images/alpine/), you can find the different tags.

Now we are inside alpine, lets print something and leave:

```
(bdf6d5c8bd01) localhost:~# date
Mon May 11 16:29:23 UTC 2020
(bdf6d5c8bd01) localhost:~# exit
$
```

You can find what images are available depending on which version of Dockie you are using:

```
$ dockie search alpine
You can open
	https://hub.docker.com/search?q=alpine&type=image
on your favorite browser
```

The previous command will point you to the URL from where Dockie is pulling the images. You can check the available images from the browser. 
 
Having said that, let's now get a Void Linux current image without using it for now:

```
$ dockie run --name my_void voidlinux:current
```

see what we got so far:

```
$ dockie ps
ROOTFS ID     IMAGE               CREATED              NAME
10bb67ac8c79  voidlinux:current   2020-05-11 17:30:42  my_void
bdf6d5c8bd01  alpine:3.11         2020-05-11 17:28:16  my_alpine
```

and now delete them both:

```
$ dockie rm 10bb67ac8c79
$ dockie rm bdf6d5c8bd01
```

but the images remain available locally in case you want to use them again:

```
$ dockie images
REPOSITORY          CREATED               SIZE
alpine:3.11         2020-05-11 17:28:16   7.9MB
voidlinux:current   2020-05-11 17:30:42   230MB
```

we can also delete them

```
$ dockie image rm alpine:3.11
$ dockie image rm voidlinux:current
```

## Other commands

Also, other commonly Docker subcommands are available:

| **Command** | **Description**                        |
| ---         | ---                                    |
| `exec`      | Run a command in a root filesystem     |
| `images`    | List images                            |
| `ls`        | List root filesystems                  |
| `import`    | Import the contents from a tarball to create an image |
| `pull`      | Pull an image                          |
| `rm`        | Remove one or more root filesystems    |
| `run`       | Run a command in a new root filesystem |

For more information on a command:

```
$ dockie COMMAND
```

