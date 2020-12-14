#!/bin/sh
set -e
set -x
. ./version.sh
if [ -n "$1" ]; then
    ARCH="$1"
else
    ARCH="aarch64"
fi
. ./functions.sh

if [ ! -d "$HOME/.gnupg" ]; then
  mkdir -p "$HOME/.gnupg"
  echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf
fi
gpg --keyserver hkp://keys.gnupg.net --recv-keys B541D55301270E0BCF15CA5D8170B4726D7198DE
rm -rf dl
mkdir dl
cd dl
curl -LO https://releases.nixos.org/nix/nix-$NIX_VERSION/nix-$NIX_VERSION-$ARCH-linux.tar.xz
curl -LO https://releases.nixos.org/nix/nix-$NIX_VERSION/nix-$NIX_VERSION-$ARCH-linux.tar.xz.asc
gpg --verify nix-$NIX_VERSION-$ARCH-linux.tar.xz.asc nix-$NIX_VERSION-$ARCH-linux.tar.xz
tar xvf nix-$NIX_VERSION-$ARCH-linux.tar.xz
cd ..

ls dl/nix-$NIX_VERSION-$ARCH-linux/store/*-bash*
STORE_BASH="/nix/store/$(basename dl/nix-$NIX_VERSION-$ARCH-linux/store/*-bash*)"
STORE_COREUTILS="/nix/store/$(basename dl/nix-$NIX_VERSION-$ARCH-linux/store/*-coreutils*)"
docker buildx build \
  --platform $platform \
  --build-arg NIX_VERSION=$NIX_VERSION \
  --build-arg ARCH=$ARCH \
  --build-arg BASH=$STORE_BASH \
  --build-arg COREUTILS=$STORE_COREUTILS \
  --progress plain \
  --load \
  --tag griff/nix-$image_arch .
docker tag griff/nix-$image_arch griff/nix-$ARCH

docker run --rm -t griff/nix-$image_arch sh -c "nix build -I nixpkgs=channel:nixos-20.09 '(with import <nixpkgs> { }; runCommand \"foo\" {} \"uname -a > \$out\")' && cat ./result"
docker run -it --rm griff/nix-$image_arch sh -l -c 'nix-env -f channel:nixos-20.09 -iA hello && test "$(hello)" = "Hello, world!"'
docker run -it --rm griff/nix-$image_arch nix-shell  -I nixpkgs=channel:nixos-20.09 -p hello --run 'test "$(hello)" = "Hello, world!"'