# shellcheck shell=bash

alias cls=clear
alias cd..="cd .."
alias mklink="ln -s"

alias C:="cd /mnt/c"
alias D:="cd /mnt/d"

git() {

  if [[ "$1" == "clone" ]]; then
    repoName=${2##*/}
    repoName=${repoName%.git}
    command git clone "$2" "$repoName" --config core.fileMode=false
    cd "$repoName" || exit 1
    echo -n "core.fileMode="
    command git config --get core.fileMode

  elif [[ "$1" == "init" ]]; then
    command git "$@" && git config core.fileMode false
    echo -n "core.fileMode="
    command git config --get core.fileMode

  else
    command git "$@"
  fi

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
