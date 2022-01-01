#!/bin/sh

./src/dockie-pull alpine

case "$(file ~/.dockie/images/alpine/*.tar)" in
*"gzip"*) exit 0 ;;
*) exit 1 ;;
esac

