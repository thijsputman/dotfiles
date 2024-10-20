# Setup `📂 ~/.bashrc.d` & `📂 ~/.profile.d`

- [Install](#install)
  - [`📂 *.d`-folders](#-d-folders)
  - [Install "à la carte"](#install-à-la-carte)
  - [Raspberry Pi](#raspberry-pi)
- [Configuration changes](#configuration-changes)
- [Software installation](#software-installation)
  - [`📂 software.d`](#-softwared)
  - [`📂 bins.d`](#-binsd)
  - [Outdated `glibc`](#outdated-glibc)
- [Git configuration](#git-configuration)
- [Uninstall](#uninstall)

## Install

After a clean install, it is recommended to
[install software](#software-installation) prior to setting up your
configuration.

1. Run `⚙️ install.sh base.d` to setup the base configuration required to use
   both [`📂 ~/.bashrc.d`](../.bashrc.d/) and
   [`📂 ~/.profile.d`](../.profile.d/)
2. Run `⚙️ install.sh` to create various configuration file symlinks and make
   some further [configuration changes](#configuration-changes)

Note that these scripts assume a "full" Ubuntu installation. Coming from a
minimal installation, the following packages (most likely) need to be installed
manually first:

```shell
apt install \
  curl \
  gpg \
  lsb-release \
  sudo \
  tzdata
```

### `📂 *.d`-folders

By default, [`📄 install.sh`](./install.sh) Runs all _executable_ files in
[`📂 config.d`](./config.d/). To instruct `📄 install.sh` to source parts from a
different folder, specify the folder-name as its first argument, e.g.
`⚙️ install.sh bins.d`.

The following folders are available:

- [`📂 base.d`](./base.d/)
- [`📂 config.d`](./config.d/)
- [`📂 software.d`](#-softwared) – part of
  [software installation](#software-installation)
- [`📂 bins.d`](#-binsd) – part of
  [software installation](#software-installation)

All scripts in these folders are idempotent. They can be run multiple times on
an already "installed" system without nasty side-effects.

### Install "à la carte"

It is possible to run only a subset of parts (in a given `folder`) by using
`⚙️ install.sh [folder] <pattern>`. This is the recommended way of running
individual parts as most of the scripts depend on variables (and
file-descriptors) set by `install.sh` and thus _cannot_ be run independently.

To run _**everything**_ inside a folder, use `⚙️ install.sh [folder] '.*'` –
this is not recommended though...

`<pattern>` Matches against the parts' filename. You can use either an exact
filename match or a regular expression. For example, `⚙️ install.sh '10-.*'`
executes `📄 config.d/10-home` and `📄 config.d/10-home-wsl` – mind the quotes
as we don't want the shell to treat the pattern as a glob...

If you specify an exact filename match (e.g. `⚙️ install.sh 10-home`), that part
is run interactively. In case of a regular expression, all matching parts are
executed non-interactively with their `stdout` and `stderr` hidden (output is
only shown in case of errors).

❗**N.B.** When running individual parts, the scripts' execute-bit (`chmod +x`)
is _ignored_. All matching scripts are thus run regardless.

### Raspberry Pi

By default, `📄 install.sh` installs the WSL2-setup. To have it install the
Raspberry Pi-setup instead, do this _prior_ to running the installer-script:

```bash
chmod +x ./{base,config}.d/*-rpi
chmod -x ./{base,config}.d/*-wsl
```

For a generic Linux-setup, do:

```bash
chmod -x ./{base,config}.d/*-{rpi,wsl}
```

## Configuration changes

The "higher-order" scripts in [`📂 config.d`](./config.d/) make configuration
changes instead of symlinking/copying files from this repo:

- [`❎ 90-auto-upgrades`](./config.d/90-auto-upgrades) — configure
  `unattended-upgrades` to check but not automatically install updates
- [`⬜ 90-gpg-agent-rpi`](./config.d/90-gpg-agent-rpi) — mask all `gpg-agent`
  related units
  - RPi-only; use a forwarded socket for GPG operations instead
- [`❎ 90-motd`](./config.d/90-motd) — removes some unnecessary clutter from the
  default MOTD
- [`⬜ 90-ubuntu-pro`](./config.d/90-ubuntu-pro) — removes additional clutter
  from MOTD and `apt` introduced by Ubuntu Pro

Scripts marked with ⬜ are not executed by default – run them
[manually via `install.sh`](#install-à-la-carte) or `chmod +x` them before
running `install.sh`.

## Software installation

Scripts in [`📂 software.d`](./software.d/) and [`📂 bins.d`](./bins.d/) install
packages/software from various sources. After a clean install it is recommended
to run these scripts _before_ allowing `install.sh` to make actual configuration
changes.

Run `⚙️ install.sh software.d` and `⚙️ install.sh bins.d` to install the minimal
recommended set of software required for an optimal (terminal) experience.

Scripts marked with ⬜ are not executed by default – run them
[manually via `install.sh`](#install-à-la-carte) or `chmod +x` them before
running `install.sh`.

❗**N.B.** The minimal recommended set doesn't install everything required for
the scripts in `📂 bashrc.d` to function. Take note of the output during
installation for further instructions...

### `📂 software.d`

- [`❎ 10-apt`](./software.d/10-apt) — basic APT setup
- [`⬜ 11-docker`](./software.d/11-docker) — Docker
- [`⬜ 11-dotnet`](./software.d/11-dotnet) — .NET
- [`❎ 11-python`](./software.d/11-python) — Python
- [`⬜ 12-git`](./software.d/12-git) — Git
- [`⬜ 12-php`](./software.d/12-php) — PHP
- [`⬜ 12-pyenv`](./software.d/12-pyenv) —
  [`pyenv`](https://github.com/pyenv/pyenv)
- [`❎ 20-snap`](./software.d/20-snap) — Snap
- [`⬜ 21-snap-gcloud`](./software.d/21-snap-gcloud) — Gcloud CLI
- [`❎ 21-snap-go`](./software.d/21-snap-go) — Go
- [`❎ 21-snap-node`](./software.d/21-snap-node) — Node
- [`⬜ 21-snap-powershell`](./software.d/21-snap-powershell) — PowerShell
- [`⬜ 30-tools-apt`](./software.d/30-tools-apt) — APT tools
- [`⬜ 30-tools-apt-extras`](./software.d/30-tools-apt-extras) — Optional APT
  tools
- [`⬜ 30-tools-gh`](./software.d/30-tools-gh) — GitHub CLI
- [`❎ 30-tools-go`](./software.d/30-tools-go) — Go tools
- [`❎ 30-tools-python`](./software.d/30-tools-python) — Python tools
- [`⬜ 40-gpu-amd-wsl`](./software.d/40-gpu-amd-wsl) — AMD GPU setup for WSL2
- [`⬜ 40-network-manager`](./software.d/40-network-manager) — Replace
  `networkd` with NetworkManager
- [`⬜ 40-qemu-amd64-rpi`](./software.d/40-qemu-amd64-rpi) — QEMU
  AMD64-emulation on Raspberry Pi
- [`⬜ 40-yubikey-wsl`](./software.d/40-yubikey-wsl) — Yubikey support for WSL2

### `📂 bins.d`

- [`⬜ act`](./bins.d/act) — [`nektos/act`](https://github.com/nektos/act)
- [`❎ fastfetch`](./bins.d/fastfetch) —
  [`fastfetch`](https://github.com/fastfetch-cli/fastfetch)
- [`⬜ hadolint`](./bins.d/hadolint) —
  [`hadolint`](https://github.com/hadolint/hadolint)
- [`⬜ litra`](./bins.d/litra) —
  [`litra-rs`](https://github.com/timrogers/litra-rs) (support for Logitech's
  Litra Glow)
- [`❎ mcfly`](./bins.d/mcfly) — [McFly](https://github.com/cantino/mcfly)
- [`⬜ rclone`](./bins.d/rclone) — [`rclone`](https://rclone.org/)
- [`⬜ shellcheck`](./bins.d/shellcheck) —
  [ShellCheck](https://www.shellcheck.net/)
- [`⬜ tdg`](./bins.d/tdg) — [`tdg`](https://gitlab.com/ribtoks/tdg)
- [`⬜ wslu`](./bins.d/wslu) — [`wslu`](https://github.com/wslutilities/wslu)

The scripts in `📂 bins.d` attempt to automatically determine the correct
processor architecture; in general they should thus work for both `amd64` and
`arm64` systems.

To install a non-predefined version of one of the binaries, do:

```shell
version=v2.12.0 install.sh bins.d hadolint
```

### Outdated `glibc`

On older distros (e.g. Ubuntu 20.04 and Debian 11 `bullseye`), issues due to an
outdated version of `glibc` start popping up. If it's not feasible to upgrade
the distro (the better solution), the below instructions offer a workaround.

The example assumes [`fastfetch`](https://github.com/fastfetch-cli/fastfetch) on
`arm64`, but it should work for other applications and architectures too –
mileage may vary...

```shell
wget -nv https://ftp.gnu.org/gnu/glibc/glibc-2.35.tar.gz
tar -zxvf glibc-2.35.tar.gz
cd glibc-2.35
mkdir glibc-build
cd glibc-build
../configure --prefix=/opt/glibc-2.35
# If "../configure" fails, one of these is probably missing:
#   gawk bison gcc make wget tar
make -j"$(nproc)"
make install
```

Then patch the executable(s) in question:

```shell
sudo patchelf \
  --set-interpreter /opt/glibc-2.35/lib/ld-linux-aarch64.so.1 \
  --set-rpath /opt/glibc-2.35/lib /usr/bin/fastfetch
```

Note that `ld-linux-aarch64.so.1` is architecture dependent...

## Git configuration

The Git user configuration (i.e., name and e-mail address) is split from the
main configuration in [`📄 ~/.gitconfig_personal`](/.gitconfig_personal). To add
additional (folder-based; dynamic) user configurations, modify
[`📄 ~/.gitconfig`](/.gitconfig) along the lines of:

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

❗ **N.B.** Both the `📄 .gitconfig` and `📄 .gitconfig_personal` files are
_copied_ (and not symlinked) from the repo.

## Uninstall

To "uninstall", run these commands in `📂 ~/`:

```bash
find -lname '**/dotfiles/**' -delete
rm -rf ~/.anacron
crontab -l | grep -v '^@hourly .* $HOME/.anacron/etc/anacrontab' | crontab -
cp /etc/skel/{.bashrc,.profile} ~/
```

This removes all symlinks pointing to `📂 **/dotfiles/**` (assuming that's what
this Git-repository is called), the `📂 ~/.anacron` folder and its
`crontab`-entry, and restores `📄 ~/.bashrc` and `📄 ~/.profile` to their
default state.

Omit `-delete` from the first command to get a list of symlinks instead of
deleting them and manually remove the ones you don't need anymore.

All files symlinked to locations _outside_ of the Git-repository are explicitly
mentioned during the installation process; you'll need to manually remove those.

Note that the above leaves behind all files they were _copied_ (instead of
symlinked) and that this does _not_ undo any of the
[configuration changes](#configuration-changes) nor (logically) the
[software installations](#software-installation).
