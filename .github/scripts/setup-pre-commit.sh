#!/usr/bin/env bash

set -euo pipefail

: "${USE_PIPX:=true}"

if ! [[ $PATH =~ (^|:)"${HOME}/.local/bin"(:|$) ]]; then
  # shellcheck disable=SC2088
  echo '~/.local/bin is not on PATH; aborting...'
  exit 1
fi

npm install -g markdownlint-cli@0.37.0
npm install -g prettier@3.0.2

pip_cmd=pip3
if [ "$USE_PIPX" == true ]; then
  pip3 install --user pipx
  pip_cmd=pipx
fi

$pip_cmd install 'pre-commit==3.3.3'
$pip_cmd install 'yamllint==1.32.0'

if ! command -v shellcheck; then
  version=v0.9.0 "${GITHUB_WORKSPACE}/install/bins.d/shellcheck"
fi

if ! command -v hadolint; then
  version=v2.12.0 "${GITHUB_WORKSPACE}/install/bins.d/hadolint"
fi

if ! command -v shfmt; then
  go install mvdan.cc/sh/v3/cmd/shfmt@v3.7.0
fi
