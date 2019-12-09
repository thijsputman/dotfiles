# shellcheck shell=bash

alias cls=clear
alias cd..="cd .."
alias mklink="ln -s"

alias C:="cd /mnt/c"
alias D:="cd /mnt/d"

generate-passphrase() {
  head /dev/urandom | tr -dc A-Za-z0-9 | head -c $1 ; echo ''
}

python-init-venv(){
  python3 -m venv .venv
  echo -e "export VIRTUAL_ENV=.venv\nlayout python-venv\n" > .envrc
  direnv allow .
  source .venv/bin/activate
  .venv/bin/python3 -m pip install --upgrade pip
}
