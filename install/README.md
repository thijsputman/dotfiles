# Install `📂 .bashrc.d`

Run `📄 install.sh` to setup [`📂 .bashrc.d`](../.bashrc.d/), create various
additional configuration file symlinks, and make some further
[small configuration changes](#configuration-changes)...

`📄 install.sh` Runs all executable files in the [`📂 parts.d`](./parts.d/)
folder. To enable/disable an install script, simply `chmod +x/-x` it.

The scripts in `📂 parts.d` are idempotent. They can be run multiple times on an
already "installed" system without nasty side-effects.

## Configuration changes

A handful of scripts in `📂 parts.d` make configuration changes instead of
symlinking files from this Git-repository:

- [`📄 90-ubuntu`](./parts.d/90-ubuntu) — removes some unnecessary clutter from
  Ubuntu's default MOTD
- [`📄 90-ubuntu-pro`](./parts.d/90-ubuntu-pro) (not enabled by default) —
  removes some additional clutter (from MOTD and `apt`) introduced by Ubuntu Pro

## Remove

To "uninstall", run the below commands in `📂 ~/`. This removes all symlinks
pointing to `📂 dotfiles` (assuming that's what this Git-repository is called)
and restores `📄 ~/.bashrc` to its default state.

```bash
find -lname '**/dotfiles/**' -delete
cp /etc/skel/.bashrc ~/.bashrc
```

Omit `-delete` to get a list of symlinks instead of deleting them and manually
remove the ones you don't need anymore.

Note that the above does _not_ undo any of the
[configuration changes](#configuration-changes).

## Raspberry Pi

By default, `📄 install.sh` installs the WSL2-setup. To have it install the
RPi-setup instead, do this prior running it:

```bash
chmod +x ./parts.d/*-rpi
chmod -x ./parts.d/*-wsl
```
