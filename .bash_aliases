# shellcheck shell=bash

# Windows/cmd.exe muscle memory
alias cls='clear'
alias cd..='cd ..'
alias tracert='traceroute'
alias ping='ping -c 4'

git() {

  if [[ ${1,,} == clone ]]; then

    repoName=${2##*/}
    repoName=${repoName%.git}

    gpg-tty
    command git clone "$2" "$repoName"
    cd "$repoName" || exit 1

  elif [[ ${1,,} =~ ^(pull|push)$ ]]; then

    gpg-tty
    command git "$@"

  else
    command git "$@"
  fi

}

gpg-tty() {
  gpg-connect-agent updatestartuptty /bye &> /dev/null
}

generate-passphrase() {
  head /dev/urandom | tr -dc A-Za-z0-9 | head -c "$1" ; echo ''
}

python-init-venv() {
  python3 -m venv .venv
  echo -e "export VIRTUAL_ENV=.venv\nlayout python-venv\n" > .envrc
  direnv allow .
  source .venv/bin/activate
  .venv/bin/python3 -m pip install --upgrade pip
}
