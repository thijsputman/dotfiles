#!/usr/bin/env bash

# ❗N.B. `set -e` is intentionally omitted here...
set -uo pipefail

rclone sync ~/.gnupg/pubring.kbx onedrive:AppData/Backups/Fw13Pro/.gnupg

rclone sync ~/.bash_history onedrive:AppData/Backups/Fw13Pro

rclone sync ~/.ssh/known_hosts onedrive:AppData/Backups/Fw13Pro/.ssh
rclone sync ~/.ssh/config.d onedrive:AppData/Backups/Fw13Pro/.ssh/config.d \
  --skip-links

rclone sync ~/.config/codespell-custom.dict \
  onedrive:AppData/Backups/Fw13Pro/.config

rclone sync ~/.local/share/mcfly/history.db \
  onedrive:AppData/Backups/Fw13Pro/.local/share/mcfly

# Backup custom Desktop-entries
rclone sync ~/.local/share/applications \
  onedrive:AppData/Backups/Fw13Pro/.local/share/applications \
  --max-depth 1 --include "/*.desktop"

# Backup (personal) Git configurations
rclone sync ~/ onedrive:AppData/Backups/Fw13Pro \
  --max-depth 1 --skip-links --include "/.gitconfig*"

# Backup htop- and btop-configuration
rclone sync ~/.config onedrive:AppData/Backups/Fw13Pro/.config \
  --max-depth 2 --skip-links --include "/{b,h}top/*"

# Backup ESPHome configuration

rclone sync ~/esphome onedrive:AppData/Backups/Fw13Pro/esphome \
  --max-depth 2 --exclude secrets.yaml --exclude .gitignore

# Remove all WPA-keys prior to uploading secrets.yaml – bit crude: The file is
# copied unconditionally (there doesn't appear to be an rclone-"native" way to
# compare modifications times)...
# We do set the remote modification time to the correct/actual time, so
# practically there's no impact (apart from superfluous uploads).
sed -E 's/^(wifi_[a-z0-9_]+:).*/\1/Ig' ~/esphome/config/secrets.yaml |
  rclone rcat onedrive:AppData/Backups/Fw13Pro/esphome/config/secrets.yaml
rclone touch onedrive:AppData/Backups/Fw13Pro/esphome/config/secrets.yaml -t \
  "$(
    date -u +"%Y-%m-%dT%H:%M:%S" -d \
      @"$(stat -c %Y ~/esphome/config/secrets.yaml)"
  )"
