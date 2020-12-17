#!/bin/sh
NIX_VERSION="$(curl -L https://nixos.org/nix/install | sed -nE 's/.*Nix ([0-9]+\.[0-9]+\.[0-9]+) binary.*/\1/p')"
if [ -z "$NIX_VERSION" ]; then
  echo "No version found. Script needs to be updated..."
  exit 1
fi

echo "NIX_VERSION=\"$NIX_VERSION\"" > version.sh
