FROM ubuntu:22.04

WORKDIR /root

COPY config/ ./

# hadolint ignore=DL3008
RUN apt-get update && apt-get install -y --no-install-recommends \
  7zip \
  gnupg2 \
  hopenpgp-tools \
  hwdata \
  paperkey \
  pcscd \
  scdaemon \
  yubikey-manager \
  yubikey-personalization && \
  rm -rf /var/lib/apt/lists/*
