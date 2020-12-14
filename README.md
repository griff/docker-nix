# [griff/nix](https://hub.docker.com/r/griff/nix)

This image contains an installation of the Nix package manager.

Use this build to create your own customized images as follows:

```
FROM griff/nix

RUN nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
RUN nix-channel --update

RUN nix-build -A pythonFull '<nixpkgs>'
````

# Limitations

By default sandboxing is turned off inside the container, even though it is
enabled in new installations of nix. This can lead to differences between
derivations built inside a docker container versus those built without any
containerization, especially if a derivation relies on sandboxing to block
sideloading of dependencies.

To enable sandboxing the container has to be started with the --privileged flag
and sandbox = true set in /etc/nix/nix.conf.


# Source

The image is built from Github repository
[griff/docker-nix](https://github.com/griff/docker-nix) using
[Github Actions](https://github.com/griff/docker-nix/actions?query=workflow%3A%22CI+to+Docker+Hub%22).