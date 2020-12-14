FROM scratch AS BUILDER
ARG ARCH=x86_64
ARG NIX_VERSION=2.3.6
ARG COREUTILS=/nix/store/7g6ar24krh7vn66gvfwwv3nq9xsh5c6i-coreutils-8.31
ARG BASH=/nix/store/x7fr0bvnwvqvr3zg60di9jxvfwimcw7m-bash-4.4-p23
COPY --chown=0:0 files /
COPY --chown=1000:1000 dl/nix-$NIX_VERSION-$ARCH-linux /nix
ENV PATH=/bin:$COREUTILS/bin:$BASH/bin
RUN ["mkdir", "-m", "777", "/bin"]
RUN ["sh", "-c", "ln -s /nix/store/*-bash-*/bin/sh /bin/sh"]
RUN mkdir -p /etc/profile.d /etc/ssl/certs /var/empty \
 && mkdir -m 777 /tmp \
 && mkdir -m 700 /app \
 && chown app:app /etc/profile.d /etc/ssl /etc/ssl/certs /app \
 && chmod a+rx /etc
USER app
ENV USER=app
RUN chmod -R a-w /nix/store/* \
 && /nix/install --no-channel-add \
 && ln -s /app/.nix-profile/etc/profile.d/nix.sh /etc/profile.d/ \
 && ln -s "$HOME/.nix-profile/etc/ssl/certs/ca-bundle.crt" /etc/ssl/certs/ca-certificates.crt \
 && ls -la /app/.nix-profile/bin \
 && /app/.nix-profile/bin/nix-env -i /nix/store/*-coreutils-* \
      /nix/store/*-bash-* \
      /nix/store/*-gnutar-* \
      /nix/store/*-xz-*-bin \
      /nix/store/*-bzip2-* \
      /nix/store/*-gzip-* \
 && rm /nix/.reginfo /nix/install /nix/*.sh /bin/sh \
 && ln -s /app/.nix-profile/bin/bash /bin/bash \
 && ln -s /app/.nix-profile/bin/sh /bin/sh \
 && /app/.nix-profile/bin/nix-store --optimise \
 && /app/.nix-profile/bin/nix-collect-garbage -d \
 && /app/.nix-profile/bin/nix-store --verify --check-contents

FROM scratch
COPY --from=BUILDER / /
USER app
WORKDIR /app
ENV \
    ENV=/etc/profile \
    TMP=/tmp \
    PATH=/app/.nix-profile/bin:/app/.nix-profile/sbin:/bin:/sbin:/usr/bin:/usr/sbin \
    GIT_SSL_CAINFO=/etc/ssl/certs/ca-certificates.crt \
    NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
    NIX_PATH=/nix/var/nix/profiles/per-user/app/channels
CMD ["/bin/bash", "-l"]