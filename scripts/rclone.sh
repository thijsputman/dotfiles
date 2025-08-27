#!/usr/bin/env bash

set -euo pipefail

rclone sync ~/.gnupg/pubring.kbx onedrive:AppData/WSL/.gnupg
rclone sync ~/.gnupg/trustedkeys.kbx onedrive:AppData/WSL/.gnupg

rclone sync ~/.env onedrive:AppData/WSL
rclone sync ~/.bash_history onedrive:AppData/WSL

rclone sync ~/.config/codespell-custom.dict onedrive:AppData/WSL/.config

rclone sync ~/.local/share/mcfly/history.db \
  onedrive:AppData/WSL/.local/share/mcfly

# Backup custom Desktop-entries
rclone sync ~/.local/share/applications \
  onedrive:AppData/WSL/.local/share/applications --max-depth 1 \
  --include "/*.desktop"

# Backup (personal) Git configuration
rclone sync ~/ onedrive:AppData/WSL --max-depth 1 --skip-links \
  --include "/.gitconfig*"

# Backup htop- and btop-configuration
rclone sync ~/.config onedrive:AppData/WSL/.config --max-depth 2 --skip-links \
  --include "/{b,h}top/*"

# Backup ESPHome configuration

rclone sync ~/esphome --max-depth 2 --exclude secrets.yaml \
  --exclude .gitignore onedrive:AppData/WSL/esphome

# Remove all WPA-keys prior to uploading secrets.yaml – bit crude: The file is
# copied unconditionally (there doesn't appear to be an rclone-"native" way to
# compare modifications times)...
# We do set the remote modification time to the correct/actual time, so
# practically there's no impact (apart from superfluous uploads).
sed -E 's/^(wifi_[a-z0-9_]+:).*/\1/Ig' ~/esphome/config/secrets.yaml |
  rclone rcat onedrive:AppData/WSL/esphome/config/secrets.yaml
rclone touch onedrive:AppData/WSL/esphome/config/secrets.yaml -t \
  "$(
    date -u +"%Y-%m-%dT%H:%M:%S" -d \
      @"$(stat -c %Y ~/esphome/config/secrets.yaml)"
  )"
