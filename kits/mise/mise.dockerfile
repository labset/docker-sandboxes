# syntax=docker/dockerfile:1
# mise's own install script (pinned to the same release tag as the binary
# below, not the floating mise.run/mise.jdx.dev URL — same trust model as
# downloading the binary directly) already handles OS/arch detection and
# checksum verification, so this stage doesn't hand-roll either. It still
# needs steering: MISE_INSTALL_MUSL forces the fully static build regardless
# of this build stage's own glibc, which is the overlay-portability property
# RECIPES.md asks for, and MISE_INSTALL_FROM_GITHUB keeps the download on
# github.com instead of the script's default mise.jdx.dev CDN mirror.
FROM dhi.io/debian-base:trixie-dev AS build
ARG MISE_VERSION
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl \
 && rm -rf /var/lib/apt/lists/*

# The pin is a claim about content: re-check the reported version after
# install.sh runs, rather than trusting that it installed what we asked for.
RUN set -eux; \
    curl -fsSL -o /tmp/install.sh \
      "https://github.com/jdx/mise/releases/download/v${MISE_VERSION}/install.sh"; \
    MISE_VERSION="v${MISE_VERSION}" \
    MISE_INSTALL_PATH=/out/usr/local/bin/mise \
    MISE_INSTALL_MUSL=1 \
    MISE_INSTALL_FROM_GITHUB=1 \
    MISE_QUIET=1 \
    sh /tmp/install.sh; \
    /out/usr/local/bin/mise --version | grep -q "${MISE_VERSION}"

# The overlay: one static binary, landing on any base — no dpkg state,
# no shared-library closure, nothing under /home.
FROM scratch
COPY --from=build /out /
