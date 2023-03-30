#!/usr/bin/env bash
# shellcheck disable=SC1090,SC2034

set -euo pipefail

bashrc=~/.bashrc
base=$(dirname "$(realpath "$(dirname "${BASH_SOURCE[0]}")")")

for file in "$base"/install/parts.d/**; do

  if [[ -x "$file" ]]; then
    echo Installing 📄 "$(basename "$file")"...
    source "$file"
  fi

done
