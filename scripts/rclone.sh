#!/usr/bin/env bash

set -euo pipefail

# Backup a handful of files that can't (sensibly) by symlinked from OneDrive's
# location in Windows (mainly due to access right restrictions) and/or where
# it's not smart to allow updates from OneDrive to be used without manual
# intervention...

rclone sync ~/.gnupg/pubring.kbx onedrive:AppData/WSL/.gnupg
rclone sync ~/.gnupg/trustedkeys.kbx onedrive:AppData/WSL/.gnupg
rclone sync ~/.ssh/config onedrive:AppData/WSL/.ssh
rclone sync ~/.bash_history onedrive:AppData/WSL/

# Backup ESPHome configuration

rclone sync ~/esphome --max-depth 1 --exclude secrets.yaml \
  onedrive:AppData/WSL/esphome/

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
