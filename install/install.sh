#!/usr/bin/env bash
# shellcheck disable=SC1090,SC2034

set -euo pipefail

base=$(dirname "$(realpath "$(dirname "${BASH_SOURCE[0]}")")")

sudo -v

for file in "$base"/install/parts.d/**; do

  file_basename="$(basename "$file")"

  if [[ (-x $file && ! -v 1) || (-v 1 && "$file_basename" =~ ^$1$) ]]; then

    # On _exact_ filename match (ie, a single file was specified), source and
    # run it interactively

    if [[ -v 1 && "$file_basename" == "$1" ]]; then

      if ! source "$file" 3>&1; then
        exit 1
      fi

    # Otherwise, capture stdout and stderr – only display them if the script
    # fails. fd 3 Is used to relay (non-fatal) warnings/notices and is thus
    # passed through to the terminal regardless.

    else

      echo "📄 $file_basename"

      if ! { output=$(source "$file" 2>&1); } 3>&1; then
        echo "$output"
        printf '\n'
        echo "⛔ Install failed – see preceding output for details..." >&2
        exit 1
      fi

    fi

  fi

done
