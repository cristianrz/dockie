#!/bin/sh
mkdir -p ~/.dockie/images/testdir

echo "my_test_guest              2022-01-01 15:33:19   5.6MB" > ~/.dockie/images/testdir/info

if ./src/dockie-image ls | grep 'my_test_guest'; then
	exit 0
else
	exit 1
fi
