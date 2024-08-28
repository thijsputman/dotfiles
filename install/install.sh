#!/usr/bin/env bash
# shellcheck disable=SC1090

set -euo pipefail

base=$(dirname "$(realpath "$(dirname "${BASH_SOURCE[0]}")")")

# Sort out which "parts"-directory to use

if [[ ! -v 1 ]]; then
  set -- config.d
fi

if [[ ! -d "$base"/install/"${1##*/}" ]]; then
  echo "⛔ Invalid parts-directory \"${1##*/}\" specified..." >&2
  exit 1
fi

folder=${1##*/}
shift

# Validate and apply additional requirements for "bins.d"-parts

if [[ $folder == bins.d ]]; then

  if [[ ! $PATH =~ (^|:)"$HOME/.local/bin"(:|$) ]]; then
    if [[ ! -d "$HOME/.local/bin" ]]; then
      mkdir -p "$HOME/.local/bin"
    fi

    echo "⚠️ Add \"📂 $HOME/.local/bin\" to PATH... "
    PATH="$PATH:$HOME/.local/bin"
  fi

  # Switch to temporary directory to prevent both unwanted interactions and
  # leaving stray files behind...
  pushd "$(mktemp -d -t install_bins-d_XXXXXX)" > /dev/null

fi

# Pre-empt sudo for software installation (almost always required)
if [[ $folder == software.d ]]; then
  sudo -v
fi

for file in "$base"/install/"$folder"/**; do

  file_basename="$(basename "$file")"

  # On _exact_ filename match (ie, a single file was specified), source and
  # run the single file; otherwise run all (executable) files

  if [[ (-x $file && ! -v 1) || (-v 1 && "$file_basename" =~ ^$1$) ]]; then

    echo "📄 $folder/$file_basename"

    # Capture stdout and stderr – only display them if the script fails. fd 3
    # Is used to relay (non-fatal) warnings/notices and is thus passed through
    # to the terminal regardless.

    output=$(
      if ! { errors=$(source "$file" 2>&1); } 3>&1; then
        echo "$errors"
        printf '\n'
        echo "⛔ Part failed – see preceding output for details..." >&2
        exit 1
      fi
    )

    readarray -t lines <<< "$output"
    for line in "${lines[@]}"; do
      echo "  $line"
    done

  fi

done

if [[ $(dirs +0) == *install_bins-d_* ]]; then
  popd > /dev/null
fi
