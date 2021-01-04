#!/usr/bin/env bash

if [ ! -e ~/.config/neofetch/config.conf ]; then
  ln -s -r "$PWD/.config/neofetch/config.conf" \
    ~/.config/neofetch/config.conf
fi

# .bashrc.d

if [ ! -e ~/.bashrc.d ]; then
  ln -s -r "$PWD/.bashrc.d" ~/.bashrc.d
fi
