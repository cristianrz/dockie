#!/bin/sh

mkdir -p ~/.dockie/guests/testguest
echo 'testpassed' >  ~/.dockie/guests/testguest/info

case "$(./src/dockie-ps)" in
*testpassed*) exit 0 ;;
*) exit 1 ;;
esac
