# Install `📂 .bashrc.d`

- [Install](#install)
  - [Prerequisites](#prerequisites)
  - [Configuration changes](#configuration-changes)
  - [Git configuration](#git-configuration)
  - [Raspberry Pi](#raspberry-pi)
- [Uninstall](#uninstall)

## Install

Run `📄 install.sh` to setup [`📂 .bashrc.d`](../.bashrc.d/), create various
configuration file symlinks, and make some further
[configuration changes](#configuration-changes).

`📄 install.sh` Runs all executable files in [`📂 install/parts.d`](./parts.d/).
To enable/disable parts of the installation, simply `chmod +x/-x` the scripts in
question prior to running the installer.

The scripts in `📂 install/parts.d` are idempotent. They can be run multiple
times on an already "installed" system without nasty side-effects.

During installation, `📄 ~/.env` is created from
[a defaults file](./../.env.default) which lists all possible environment
variables (without setting any of their values). Make sure to fill out all
relevant environment variables before continuing.

### Prerequisites

The below software should be installed for the scripts in `📂 .bashrc.d` to
function properly.

- **neofetch** — `sudo apt install neofetch`
- **direnv** — `sudo apt install direnv`
- **pyenv** — `curl https://pyenv.run | bash`
- **powerline-go** — retrieve the latest binary from
  <https://github.com/justjanne/powerline-go> and store as
  `📄 ~/.local/bin/powerline-go`.

Note that none of these dependencies pose a hard requirement; missing
dependencies are handled gracefully by the various scripts.

### Configuration changes

A handful of scripts in `📂 parts.d` make configuration changes instead of
symlinking files from this Git-repository:

- 🟢 [`📄 90-ubuntu`](./parts.d/90-ubuntu) — removes some unnecessary clutter
  from Ubuntu's default MOTD
- 🚫 [`📄 90-ubuntu-pro`](./parts.d/90-ubuntu-pro) — removes additional clutter
  from MOTD and `apt` introduced by Ubuntu Pro
- 🚫 [`📄 91-apt-add-repository`](./parts.d/91-apt-add-repository) — adds a set
  of third-party `apt`-repositories (Node.js, Microsoft, etc.)

Scripts marked with 🚫 are not executable by default.

### Git configuration

The Git user configuration (i.e., name and e-mail address) is split from the
main configuration in `📄 ~/.gitconfig_personal`. To add additional
(folder-based; dynamic) user configurations, modify `📄 ~/.gitconfig` along the
lines of:

```conf
[include]
  path = .gitconfig_personal
[includeIf "gitdir:GitHub/folder_XXX/"]
  path = .gitconfig_XXX
[includeIf "gitdir:GitHub/folder_YYY/"]
  path = .gitconfig_YYY
[alias]
  ...
```

### Raspberry Pi

By default, `📄 install.sh` installs the WSL2-setup. To have it install the
Raspberry Pi-setup instead, do this prior running the installer:

```bash
chmod +x ./parts.d/*-rpi
chmod -x ./parts.d/*-wsl
```

## Uninstall

To "uninstall", run these commands in `📂 ~/`:

```bash
find -lname '**/dotfiles/**' -delete
rm ~/.env
cp /etc/skel/.bashrc ~/.bashrc
```

This removes all symlinks pointing to `📂 **/dotfiles/**` (assuming that's what
this Git-repository is called), removes the `📄 ~/.env` created during
installation, and restores `📄 ~/.bashrc` to its default state.

Omit `-delete` from the first command to get a list of symlinks instead of
deleting them and manually remove the ones you don't need anymore.

Note that this does _not_ undo any of the
[configuration changes](#configuration-changes).
