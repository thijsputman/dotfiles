#!/usr/bin/env bash

set -euo pipefail

if [ -d "$HOME/.pyenv" ]; then

  logger -t pyenv "Checking for updates..."

  rm -f ~/.pyenv-update

  cd "$HOME/.pyenv" || exit
  git remote update

  if [[ $(git rev-parse HEAD) != $(git rev-parse '@{u}') ]]; then

    status=$(git status | head -n 2 | tail -n 1)

    if [[ $status == *behind* ]]; then

      echo "${status/Your branch/pyenv}" >> ~/.pyenv-update
      printf 'To upgrade run: pyenv update' >> ~/.pyenv-update

      logger -t pyenv "Update available!"

    fi

  fi

fi
