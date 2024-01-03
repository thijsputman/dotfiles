#!/usr/bin/env bash
# shellcheck disable=SC1090,SC2034

set -euo pipefail

bashrc=~/.bashrc
base=$(dirname "$(realpath "$(dirname "${BASH_SOURCE[0]}")")")

for file in "$base"/install/parts.d/**; do

  file_basename="$(basename "$file")"

  if [[ (-x $file && ! -v 1) || (-v 1 && $1 == "$file_basename") ]]; then
    echo Installing 📄 "$file_basename"...
    source "$file"
  fi

done
