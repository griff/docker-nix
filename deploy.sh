#!/bin/sh
set -e
set -x
. version.sh
if [ -n "$1" ]; then
    ARCH="$1"
else
    ARCH="aarch64"
fi
. functions.sh

docker push griff/nix-$image_arch
docker push griff/nix-$ARCH