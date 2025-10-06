FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
  7zip=23.01+\* \
  gnupg2=2.4.4-\* \
  hopenpgp-tools=0.23.7-\* \
  hwdata=0.379-\* \
  paperkey=1.6-\* \
  pcscd=2.0.3-\* \
  scdaemon=2.4.4-\* \
  yubikey-manager=5.2.1-\* \
  yubikey-personalization=1.20.0-\* && \
  rm -rf /var/lib/apt/lists/*

COPY rootfs/ /
