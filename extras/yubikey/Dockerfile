FROM ubuntu:22.04

WORKDIR /root

COPY config/ ./

RUN apt update && \
  apt -y install \
    7zip \
    gnupg2 \
    hopenpgp-tools \
    hwdata \
    paperkey \
    pcscd \
    scdaemon \
    yubikey-manager \
    yubikey-personalization

