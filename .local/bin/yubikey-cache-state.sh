#!/usr/bin/env bash

# shellcheck source=.profile.d/01-dotenv
source ~/.profile.d/01-dotenv

usbip_out=$(mktemp --tmpdir yubikey-usbip.XXXXXX)
# shellcheck disable=SC2064
trap "rm -f $usbip_out" EXIT

# shellcheck disable=SC2024
if sudo usbip port > "$usbip_out" 2>&1; then
  if [[ -n $USBIP_HOST && -n $USBIP_BUSID &&
    $(< "$usbip_out") =~ usbip://$USBIP_HOST:3240/$USBIP_BUSID ]]; then
    echo attached > ~/.yubikey-state
  else
    echo detached > ~/.yubikey-state
  fi
else
  rm -f ~/.yubikey-state
fi
