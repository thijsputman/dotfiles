#!/usr/bin/env bash

if [ ! -e ~/.config/neofetch/config.conf ]; then
  mkdir -p ~/.config/neofetch
  ln -s -r "$PWD/.config/neofetch/config-pi4.conf" \
    ~/.config/neofetch/config.conf
fi

if [ ! -e ~/.inputrc ]; then
  ln -s -r "$PWD/.inputrc" ~/.inputrc
fi

if [ ! -e ~/.nanorc ]; then
  ln -s -r "$PWD/.nanorc" ~/.nanorc
fi

# .bashrc.d

if [ ! -e ~/.bashrc ]; then
  ln -s -r "$PWD/.bashrc" ~/.bashrc
fi

if [ ! -e ~/.bashrc.d ]; then
  ln -s -r "$PWD/.bashrc.d" ~/.bashrc.d
fi

if [ -d ~/.bashrc.d ] && [ -L ~/.bashrc.d ]; then

  chmod +x ~/.bashrc.d/05-pi4 \
    ~/.bashrc.d/20-gpg-pi4

  chmod -x ~/.bashrc.d/05-wsl \
    ~/.bashrc.d/06-wsl-ip \
    ~/.bashrc.d/20-gpg-wsl

fi

# Git

if [ ! -e ~/.gitattributes_global ]; then
  ln -s -r "$PWD/.gitattributes_global" ~/.gitattributes_global
fi

if [ ! -e ~/.gitconfig ]; then
  ln -s -r "$PWD/.gitconfig" ~/.gitconfig
fi

if [ ! -e ~/.gitignore_global ]; then
  ln -s -r "$PWD/.gitignore_global" ~/.gitignore_global
fi
