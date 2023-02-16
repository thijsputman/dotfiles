# Collection of Personal `.files`

Personalising an **Ubuntu 22.04** (or **20.04**) installation.

- [Bash-scripts](#bash-scripts)
- [Static modifications](#static-modifications)
  - [WSL2](#wsl2)
- [Extras](#extras)
- [TODO](#todo)

## Bash-scripts

The core of this repository is a set of Bash-scripts in
[`📂 .bashrc.d`](./.bashrc.d/) that are sourced as part of `📄 ~/.bashrc`.

See [`📂 install`](./install/README.md) for installation instructions.

## Static modifications

Apart from the Bash-scripts, there's a set of static/manual modifications in
[`📂 static`](./static/README.md).

### WSL2

To setup a WSL2 instance, _copy_ [`📄 wsl.conf`](./static/linux/etc/wsl.conf)
and [`📄 resolv.conf`](./static/linux/etc/resolv.conf) to `📂 /etc` — on the
Windows-side, copy [`📄 .wslconfig`](./static/windows/.wslconfig) and
[`📄 .wslgconfig`](./static/windows/.wslgconfig) to `📂 %USERPROFILE%`.

Several of the Bash-scripts rely on the modifications made in these
configuration files to function properly.

#### systemd

In their default state, the Bash-scripts and configuration files assume the WSL2
instance is running **`systemd`**.

When using Microsoft's `/init` system, copy
[`📄 wsl.init.conf`](./static/linux/etc/wsl.init.conf) to `📂 /etc` instead (and
rename it to `📄 wsl.conf`) and `chmod +x`
[`📄 .bashrc.d/30-x11-wsl`](./.bashrc.d/30-x11-wsl).

In this case no services are started automatically, so several required services
are started through `📄 /etc/wsl.conf`. Furthermore, a `dbus`-session (required
for X11/GUI-applications) is launched.

## Extras

See [`📂 extras`](./extras/README.md).

## TODO

See [`📄 TODO`](./TODO).
