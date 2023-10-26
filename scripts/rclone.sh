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
