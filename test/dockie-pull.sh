#!/bin/sh

./src/dockie-pull alpine

case "$(file ~/.dockie/images/alpine/rootfs.tar)" in
*"POSIX tar"*) exit 0 ;;
*) exit 1 ;;
esac

