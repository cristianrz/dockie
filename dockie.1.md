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

Images are not hashed or identified uniquely in any way. This means that if
an ubuntu:latest image is downloaded and later on another ubuntu:latest image
is downloaded which differs from the previous (i.e. an update has been
released), Dockie will overwrite the previous image and will not keep track
of different versions. If an advanced user would need to keep track of
different versions of the same image, the import subcommand should be used.

## Importing

Dockie also allows importing local images as tarballs. These tarballs need to
only contain the root file system as Dockie will take care of the metadata. The
only accepted format is .tar. The name of the file will be used as the name of
the image so it is recommended not to use files such as rootfs.tar without
renaming them first.

## Running

The run command is effectively a combination of three steps:

* pull: if the image is not available locally and is available on the remote
repository Dockie pulls it from the repository. 
* bootstrap: the tarball is extracted into a newly created directory inside the
guests directory. /etc/profile and /etc/resolv.conf are created at this point.
Note that Dockie will always replace the existing resolv.conf file on bootstrap
but later changes to the file will be preserved.
* exec: if a command is passed, Dockie will exec the passed command inside the
guest.

This means that there are two ways to initialise Dockie guests. The first one
is with an initial pull and the run, which will use the existing downloaded
image. Guests can also be downloaded implictly, i.e. if a guest wants to be
initialised with and image that is not inside the images directory, Dockie
will automatically pull that image and initialise the guest.

Run will always create a new guest and assign it a unique ID. It extracts the
selected image if it is available locally, otherwise it pulls it from the
configured remote repository. If a command is specified it also runs the
command. 

Guests are inside the guests directory and include the rootfs directory as well
as a formatted metadata file.

## Executing

For guests that have already been creating, the exec subcommand will execute a
command inside the guest, usually /bin/sh or /bin/bash, but any command can be
used.

Each guest has an unique ID assigned to it, which can be checked with the ls
command. To execute commands on a guest this ID needs to be used.

When executing PRoot, if a username has been passed as a command-line argument
it looks for the ID in the etc/password file to log in as that specified user.
With that username it also sets the HOME environment variable. On exec, the
DISPLAY, TERM, BASH_ENV and ENV are passed to the guest. Both DISPLAY and TERM
have the same value as the guest while BASH_ENV and ENV are set to /etc/profile
to force the guest to read the profile and therefore setting PS1 according to
what Dockie specified during the bootstrap process.

To avoid removing guests that are being used, when using exec, Dockie creates
a lock file inside the guest directory (but outside of the root) so that rm
can warn against removing locked guests. If the file is prevented from being
deleted (e.g. using chattr or making the parent directory read-only), this
will efectively prevent that guest from being removed from Dockie.



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

# ENVIRONMENT

DOCKIE_ARCH
: Target architecture for pulled images, if unset it defaults to amd64

DOCKIE_PATH
: Location for images and guests. If unset, it defaults to
$HOME/.local/var/lib/dockie

# SEE ALSO

proot(1), chroot(1)

# AUTHORS

Cristian Ariza
: Initial design
