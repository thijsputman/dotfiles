#!/usr/bin/env bash

set -euo pipefail

if [ -n "$PYENV_ROOT" ]; then

  rm ~/.pyenv-update

  cd "$PYENV_ROOT" || exit
  git remote update

  if [[ $(git rev-parse HEAD) != $(git rev-parse '@{u}') ]]; then

    status=$(git status | head -n 2 | tail -n 1)

    if [[ $status == *behind* ]]; then
      echo "${status/Your branch/pyenv}" >> ~/.pyenv-update
      printf 'To upgrade run: pyenv update' >> ~/.pyenv-update
    fi

  fi

fi
