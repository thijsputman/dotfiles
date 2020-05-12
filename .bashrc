# shellcheck shell=bash
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=2000
HISTFILESIZE=20000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
  debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
  xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
  if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
  else
    color_prompt=
  fi
fi

if [ "$color_prompt" = yes ]; then
  PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
  PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
  *)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
  test -n "$LS_COLORS" || { test -r ~/.dircolors && \
    eval "$(dircolors -b ~/.dircolors)"; } || eval "$(dircolors -b)"

  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

## ==>                    End of Ubuntu 20.04 ".bashrc"                   <== ##

# Powerline Go
PWRLN_MODULES=nix-shell,venv,user,ssh,cwd,perms,git,docker,jobs,exit,root,vgo
PWRLN_ALIASES=/mnt/c=C:,/mnt/d=D:,~/GitHub=GIT

function _powerline_ps1() {
  PS1="$(powerline-go -error $? -cwd-max-depth 3 -modules $PWRLN_MODULES -path-aliases $PWRLN_ALIASES)"
}

if [ "$TERM" != "linux" ] && [ -f "$HOME/.local/bin/powerline-go" ]; then
  PROMPT_COMMAND='_powerline_ps1; echo -ne "\033]0;${debian_chroot:+($debian_chroot)}${USER}@${HOSTNAME}: $(dirs +0)\007"'
fi

# GPG-Agent
GPG_TTY=$(tty)
export GPG_TTY

# Use GPG-Agent for SSH
# https://wiki.archlinux.org/index.php/GnuPG#SSH_agent

unset SSH_AGENT_PID
if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then

  SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
  export SSH_AUTH_SOCK

  gpg-connect-agent updatestartuptty /bye &> /dev/null

fi

# X11 / VcXsrv
# Only export these when VcXsrv (X11) is running; otherwise many things (i.e.
# depending on dbus; e.g. Python, screenfetch) will start to fail...

if timeout 0.1 nc -z x1carbon.sgraastra 6000 ; then

    LIBGL_ALWAYS_INDIRECT=1
    DISPLAY=x1carbon.sgraastra:0.0
    export \
      LIBGL_ALWAYS_INDIRECT \
      DISPLAY

    if [ -z "$DBUS_SESSION_BUS_ADDRESS" ] ; then
        eval "$(dbus-launch --sh-syntax --exit-with-session)"
    fi

fi

# Initialise direnv
eval "$(direnv hook bash)"

# PATH additions

# Manually append (relevant) Windows path-entries for WSL-interop
PATH+=:/mnt/c/WINDOWS/system32
PATH+=:/mnt/c/WINDOWS
PATH+=:/mnt/c/Users/Thijs/AppData/Local/Programs/Microsoft\ VS\ Code/bin
PATH+=:/mnt/c/Program\ Files/Docker/Docker/resources/bin
PATH+=:/mnt/c/Users/Thijs/AppData/Local/Microsoft/WindowsApps

export PATH

# If we're not showing the full MOTD, show its header line

if [ -z "$MOTD_SHOWN" ]; then
    . /etc/update-motd.d/00-header
    printf "\n"
fi

