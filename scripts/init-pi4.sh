#!/usr/bin/env bash

ln -s "$PWD/.config/neofetch/config-pi4.conf" ~/.config/neofetch/config.conf

# .bashrc.d

ln -s "$PWD/.bashrc.d" ~/.bashrc.d

chmod +x ~/.bashrc.d/01-pi4 \
  ~/.bashrc.d/20-gpg-pi4

chmod -x ~/.bashrc.d/01-wsl \
  ~/.bashrc.d/20-gpg \
  ~/.bashrc.d/40-path
