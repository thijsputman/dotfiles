# Install `📂 .bashrc.d`

- [Run individual parts](#run-individual-parts)
- [Raspberry Pi](#raspberry-pi)
- [Configuration changes](#configuration-changes)
- [Package installation](#package-installation)
  - [`bins.d`](#binsd)
  - [Outdated `glibc`](#outdated-glibc)
- [Git configuration](#git-configuration)
- [Uninstall](#uninstall)

Run [`📄 install.sh`](./install.sh) to setup [`📂 ~/.bashrc.d`](../.bashrc.d/)
and [`📂 ~/.profile.d`](../.profile.d/), create various configuration file
symlinks, make some further [configuration changes](#configuration-changes), and
optionally [install required packages](#package-installation).

❗ **N.B.** After a clean install, it is recommended
[to install packages](#package-installation) prior to running a "bare"
`install.sh`.

`📄 install.sh` Runs all _executable_ files in [`📂 parts.d`](./parts.d/). To
enable/disable parts of the installation, simply `chmod +x/-x` the scripts in
question prior to running the installer.

The scripts in `📂 parts.d` are idempotent. They can be run multiple times on an
already "installed" system without nasty side-effects.

During installation, `📄 ~/.env` is created from
[a defaults file](/.env.default) which lists all possible environment variables
(without setting any of their values). Make sure to fill out all relevant
environment variables before continuing.

## Run individual parts

It is possible to run only a subset of parts by using `install.sh <pattern>`.
This is the recommended way of running individual parts as most of them depend
on variables (and file-descriptors) set by `install.sh` and thus _cannot_ be run
independently.

The `<pattern>` matches against the parts' filename only. You can use either an
exact filename match or a regular expression. For example, `install.sh 20-.*`
executes `📄 parts.d/20-home` and `📄 parts.d/20-home-wsl`.

If you specify an exact filename match (e.g. `install.sh 20-home`), that script
is run interactively. In case of a regular expression, all matching scripts are
executed (with their `stdout` hidden; only shown in case of errors).

Note that when running individual parts, the scripts' execute-bit (`chmod +x`)
is _ignored_. All matching scripts are run regardless.

## Raspberry Pi

By default, `📄 install.sh` installs the WSL2-setup. To have it install the
Raspberry Pi-setup instead, do this prior running the installer:

```bash
chmod +x ./parts.d/*-rpi
chmod -x ./parts.d/*-wsl
```

## Configuration changes

The "higher-order" scripts in [`📂 parts.d`](./parts.d/) make configuration
changes instead of symlinking/copying files from this repo:

- [`❎ 90-auto-upgrades`](./parts.d/90-auto-upgrades) — configure
  `unattended-upgrades` to check but not automatically install updates
- [`⬜ 90-gpg-agent-rpi`](./parts.d/90-gpg-agent-rpi) — mask all `gpg-agent`
  related units
  - RPi-only; use a forwarded socket for GPG operations instead
- [`❎ 90-motd`](./parts.d/90-motd) — removes some unnecessary clutter from the
  default MOTD
- [`⬜ 90-ubuntu-pro`](./parts.d/90-ubuntu-pro) — removes additional clutter
  from MOTD and `apt` introduced by Ubuntu Pro

Scripts marked with ⬜ are not executable by default – run them manually via
`install.sh` (e.g. `install.sh 90-ubuntu-pro`) or `chmod +x` them before calling
`install.sh`.

## Package installation

Scripts numbered `91` and above install packages/software from various sources.
After a clean install it is recommended to run these scripts _before_ running a
"bare" `install.sh`.

To install _**all**_ packages, run **`install.sh '9[1-3]{1}-.*'`**.

Alternatively, cherry-pick the software you'd like to have installed (e.g., run
`install.sh '9[1-3]{1}-.*-python'` to install all Python-related packages).

For an optimal terminal-experience, the scripts marked with ❎ should be
executed:

- [`❎ 91-apt-install`](./parts.d/91-apt-install) — required APT-packages
- [`⬜ 91-apt-install-docker`](./parts.d/91-apt-install-docker) — Docker
- [`⬜ 91-apt-install-dotnet`](./parts.d/91-apt-install-dotnet) — .NET SDK
- [`⬜ 91-apt-install-git`](./parts.d/91-apt-install-git) — Git (and related
  tools)
- [`⬜ 91-apt-install-gpu-amd`](./parts.d/91-apt-install-gpu-amd) — AMD GPU
  support (Vulkan/Mesa drivers)
- [`⬜ 91-apt-install-php`](./parts.d/91-apt-install-php) — PHP
- [`⬜ 91-apt-install-python`](./parts.d/91-apt-install-python) — Python, `pip`
  & [`pyenv`](https://github.com/pyenv/pyenv)
- [`❎ 91-apt-install-snap`](./parts.d/91-apt-install-snap) — Snap & XDG Desktop
  Portal
  - enabled by default on Ubuntu – there the script only installs XDG Desktop
    Portal
- [`⬜ 91-apt-install-yubikey`](./parts.d/91-apt-install-yubikey) — Yubikey
  (including [`usbipd-win`](https://github.com/dorssel/usbipd-win) interop)
- [`⬜ 92-snap-install-gcloud`](./parts.d/92-snap-install-gcloud) — `gcloud` CLI
- [`❎ 92-snap-install-go`](./parts.d/92-snap-install-go) — Go
- [`⬜ 92-snap-install-node`](./parts.d/92-snap-install-node) — Node & `npm`
- [`⬜ 92-snap-install-powershell`](./parts.d/92-snap-install-powershell) —
  PowerShell
- [`⬜ 93-tools-install-apt`](./parts.d/93-tools-install-apt) — additional tools
  (APT-packages)
- [`❎ 93-tools-install-bins`](./parts.d/93-tools-install-bins) — install all
  tools in [`📂 bins.d`](#binsd)
  - includes [`fastfetch`](https://github.com/fastfetch-cli/fastfetch) and
    [`mcfly`](https://github.com/cantino/mcfly) (relevant for the
    terminal-experience)
- [`⬜ 93-tools-install-gh`](./parts.d/93-tools-install-gh) — tools for the
  GitHub CLI
- [`❎ 93-tools-install-go`](./parts.d/93-tools-install-go) — additional tools
  (written in Go)
  - includes [`powerline-go`](https://github.com/justjanne/powerline-go)
    (relevant for the terminal-experience)
- [`⬜ 93-tools-install-python`](./parts.d/93-tools-install-python) — additional
  tools (written in Python)

Note that these scripts assume a "full" Ubuntu installation. Coming from a
minimal installation, the following packages (most likely) need to be installed
first:

```shell
apt install \
  curl \
  gpg \
  lsb-release \
  sudo \
  tzdata
```

### `bins.d`

A handful of convenience scripts are provided that either pull binaries directly
from GitHub, or have fully customised installation procedures.

Simply run any of the scripts in [`📂 bins.d`](./bins.d) to pull the predefined
version of the tool into `📂 ~/.local/bin` – or `📂 ~/.go/bin` for tools
compiled from Go, overwriting any pre-existing version of the tool.

The scripts pulling in binaries attempt to automatically determine the correct
processor architecture; in general they should thus work for both `amd64` and
`arm64` systems.

To install a non-predefined version of a tool, do:

```shell
version=v2.12.0 ./hadolint
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
[configuration changes](#configuration-changes) nor the
[package installations](#package-installation).
