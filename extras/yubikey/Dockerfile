FROM ubuntu:22.04

WORKDIR /root

COPY config/ ./

RUN apt-get update && apt-get install -y --no-install-recommends \
  7zip=21.07+\* \
  gnupg2=2.2.27-\* \
  hopenpgp-tools=0.23.6-\* \
  hwdata=0.357-\* \
  paperkey=1.6-\* \
  pcscd=1.9.5-\* \
  scdaemon=2.2.27-\* \
  yubikey-manager=4.0.7-\* \
  yubikey-personalization=1.20.0-\* && \
  rm -rf /var/lib/apt/lists/*
