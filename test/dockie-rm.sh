#!/bin/sh 

set -eu

mkdir -p ~/.dockie/guests/testguest

./src/dockie-rm testguest

! [ -f ~/.dockie/guests/testguest ]

