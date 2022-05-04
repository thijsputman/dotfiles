#!/usr/bin/env bash

if [ ! -e ~/.config/neofetch/config.conf ]; then
  ln -s -r "$PWD/.config/neofetch/config.conf" \
    ~/.config/neofetch/config.conf
fi

if [ ! -e ~/.config/powerline-go/config.json ]; then
  ln -s -r "$PWD/.config/powerline-go/config-wsl.json" \
    ~/.config/powerline-go/config.json
fi

# .bashrc.d

if [ ! -e ~/.bashrc.d ]; then
  ln -s -r "$PWD/.bashrc.d" ~/.bashrc.d
fi
