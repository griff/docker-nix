oops() {
    echo "$0:" "$@" >&2
    exit 1
}

case "$ARCH" in
    x86_64) image_arch=amd64; platform=linux/amd64;;
    i686) image_arch=i386; platform=linux/386;;
    aarch64) image_arch=arm64v8; platform=linux/arm64/v8;;
    *) oops "sorry, there is no binary distribution of Nix for platform $ARCH";;
esac
