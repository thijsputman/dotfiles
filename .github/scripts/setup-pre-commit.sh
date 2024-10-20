#!/usr/bin/env bash

set -euo pipefail

: "${USE_PIPX:=true}"
: "${FORCE_INSTALL:=false}"

# Provide a proper $GITHUB_WORKSPACE for local invocations (ie, two levels up
# from the folder this script is in)
: "${GITHUB_WORKSPACE:=$(dirname \
  "$(realpath "$(dirname "${BASH_SOURCE[0]}")/../") \
  ")}"

# Some of the scripts included below assume (if not explicitly specified) a non-
# standard location for GOPATH – by explicitly setting it to the standard
# location (for actions/setup-go) here, the problem is avoided...
: "${GOPATH:="$HOME/go"}"
export GOPATH

if ! [[ $PATH =~ (^|:)"${HOME}/.local/bin"(:|$) ]]; then
  echo "$HOME/.local/bin is not on PATH; aborting..." >&2
  exit 1
fi

npm install -g markdownlint-cli@0.37.0
npm install -g prettier@3.0.2

pip_cmd=pip3
if [[ ${USE_PIPX,,} == 'true' ]]; then
  (
    export PIP_REQUIRE_VIRTUALENV=false
    export PIP_BREAK_SYSTEM_PACKAGES=1
    pip3 install --user pipx
  )
  pip_cmd=pipx
fi

$pip_cmd install 'pre-commit==3.3.3'
$pip_cmd install 'yamllint==1.32.0'
$pip_cmd install 'codespell==2.3.0'

if ! command -v shellcheck || [[ ${FORCE_INSTALL,,} == 'true' ]]; then
  version=v0.9.0 "${GITHUB_WORKSPACE}/install/install.sh" bins.d shellcheck
fi

if ! command -v hadolint || [[ ${FORCE_INSTALL,,} == 'true' ]]; then
  version=v2.12.0 "${GITHUB_WORKSPACE}/install/install.sh" bins.d hadolint
fi

if ! command -v tdg || [[ ${FORCE_INSTALL,,} == 'true' ]]; then
  version=v0.0.2 "${GITHUB_WORKSPACE}/install/install.sh" bins.d tdg
fi

if ! command -v shfmt || [[ ${FORCE_INSTALL,,} == 'true' ]]; then
  go install mvdan.cc/sh/v3/cmd/shfmt@v3.7.0
fi
