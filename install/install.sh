#!/usr/bin/env bash
# shellcheck disable=SC1090

set -euo pipefail

base="$(dirname "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")"

# shellcheck disable=SC2317
goodbye() {

  rc="$?"

  # Reset EXIT-trap to prevent getting stuck in "goodbye" (due to "set -e")
  trap - EXIT

  # Exit from – and remove – the "bins.d" temporary directory
  if [[ $(dirs +0) == *install_bins-d_* ]]; then
    temp_dir="$(dirs +0)"
    popd > /dev/null || exit 1
    rm -rf "$temp_dir"
  fi

  exit "$rc"
}

trap goodbye INT TERM EXIT 0

# If no (valid) parts-directory is specified, default to "config.d"

if [[ ! -v 1 ]]; then
  set -- config.d
elif [[ $1 != *.d ]]; then
  set -- config.d "$1"
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

  # Switch to temporary directory to prevent unwanted interactions and/or
  # leaving stray files behind...
  pushd "$(mktemp -d -t install_bins-d_XXXXXX)" > /dev/null || exit 1

fi

# Preempt sudo for software installation (almost always required)
if [[ $folder == software.d ]]; then
  sudo -v
fi

exit_code=0
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
        echo "⛔ Part failed – see preceding output for details..."
        false
      fi
    ) || exit_code=1

    readarray -t lines <<< "$output"
    for line in "${lines[@]}"; do
      echo "  $line"
    done

  fi

done

exit "$exit_code"
