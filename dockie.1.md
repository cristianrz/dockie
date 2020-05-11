% DOCKIE(1)

# NAME

Dockie - manage unprivileged chroot environments

# SYNOPSIS

dockie [-dhv] {exec | image | ls | import | pull | rm | run | search}

# DESCRIPTION

Dockie is a wrapper around PRoot to manage unprivileged chroots with a familiar
interface.

PRoot, and therefore Dockie, are not security features and should not be used
as such. PRoot should only be used as a "soft sandbox" where you can:

* test some other distros features,
* fake root privileges or
* build packages from source without polluting your environment

knowing that whatever gets into your PRoot will be able to get out into your
host OS.

## Pulling

Dockie is able to pull packages from either the LXC image server or from the
Docker Hub. LXC support is native to Dockie and Docker Hub's is done through
a contrib script included with the Dockie releases.

Dockie stores its data inside DOCKER_PATH, if the environment variable is set,
otherwise inside HOME/.local/var/lib/dockie.

To pull images the image and version need to be speicifed from the command line
in the form of image:version. Images that have been either pulled from a remote
repository are stored inside the images directory as a tarball together with a
file containing its formatted metadata.

As the repositories are provided by third-parties there is no built-in search
mechanism. The search comnmand will output the URL of the repository where the
user can browse the available images.

## Importing

Dockie also allows importing local images as tarballs. These tarballs need to
only contain the root file system as Dockie will take care of the metadata.
The name of the file will be used as the name of the image so it is recommended
not to use files such as rootfs.tar.

## Running

To use these images the run subcommand is used. Run will always create a new 
guest and assign it a unique ID. It extracts the selected image if it is
available locally, otherwise it pulls it from the configured remote repository.
If a command is specified it also runs the command. This environment is called
a guest.

Guests are inside the guests directory and include the rootfs directory as well
as a formatted metadata file.

## Executing

For guests that have already been creating, the exec subcommand will execute a
command inside the guest, usually /bin/sh or /bin/bash, but any command can be
used.

## Options

-d
: Debug mode

-h
: Print usage

-v
: Print version information and quit

--gui
: If used with exec, mounts /var/lib/dbus/machine-id, /run/shm, /proc and /dev
from the host

--install
: If used with exec, this option is useful to safely create and install packages into the guest
rootfs. It mounts the following files/directories from the host: /etc/host.conf,
/etc/hosts, /etc/nsswitch.conf, /etc/resolv.conf, /dev/, /sys/, /proc/, /tmp/,
/run/shm, HOME and path. It is equivalent to proot -S.

--user
: If used with exec, specify the username.

## Subcommands

exec _id_ _command_
: Run a command in a root filesystem identified by an id.

image ls
: List images

image rm
: Remove one or more images

ls
: List guest filesystems

import _file_
: Import the contents from a tarball to create an image

pull _image_
: Pull an image

rm _id_
: Remove one or more root filesystems

run _id_ _command_
: Run a command in a new root filesystem

search
: Print the URL of the remote repository

