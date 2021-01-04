#!/usr/bin/env bash

if [ ! -e ~/.config/neofetch/config.conf ]; then
  ln -s -r "$PWD/.config/neofetch/config-pi4.conf" \
    ~/.config/neofetch/config.conf
fi

# .bashrc.d

if [ ! -e ~/.bashrc.d ]; then
  ln -s -r "$PWD/.bashrc.d" ~/.bashrc.d
fi

if [ -d ~/.bashrc.d ] && [ -L ~/.bashrc.d ]; then

  chmod +x ~/.bashrc.d/01-pi4 \
    ~/.bashrc.d/20-gpg-pi4

  chmod -x ~/.bashrc.d/01-wsl \
    ~/.bashrc.d/20-gpg \
    ~/.bashrc.d/40-path

fi
