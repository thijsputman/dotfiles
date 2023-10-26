# Collection of Personal `.files`

Personalising an **Ubuntu 22.04** installation.

- [Bash-scripts](#bash-scripts)
- [Static modifications](#static-modifications)
  - [WSL2](#wsl2)
- [Development](#development)
  - [Linter / pre-commit](#linter--pre-commit)
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

To setup a WSL2 instance, _copy_ [`📄 wsl.conf`](./static/linux/etc/wsl.conf) to
`📂 /etc` — on the Windows-side, copy
[`📄 .wslconfig`](./static/windows/.wslconfig) and
[`📄 .wslgconfig`](./static/windows/.wslgconfig) to `📂 %USERPROFILE%`.

Several of the Bash-scripts rely on the modifications made in these
configuration files to function properly.

#### systemd

In their default state, the Bash-scripts and configuration files assume the WSL2
instance is running **`systemd`**. See
[`📂 static/linux/etc`](./static/linux/etc/README.md) for instructions on how to
use Microsoft's `/init` instead.

#### systemd - Caveats

Although generally speaking, systemd works fine, there's a handful of caveats to
be aware of:

- It is recommended to change the default target to "multi-user.target":
  - `sudo systemctl set-default multi-user.target`
  - See <https://github.com/arkane-systems/bottle-imp#requirements>
- To prevent `systemd-remount-fs` from failing (resulting in a
  "degraded"-state), remove the `LABEL=cloudimg-rootfs`-line from `/etc/fstab`
  - Ubuntu-specific – apart from this, fstab should be empty; as the entry
    didn't do anything to begin with (no filesystem labelled `cloudimg-rootfs`
    present) it seems safe to remove...
  - See <https://randombytes.substack.com/i/74583493/systemd-remount-fsservice>
- See [`📂 /usr/lib/binfmt.d`](static/linux/usr/lib/binfmt.d/README.md) if
  you're running into issues with **WSL-interop**

## Development

### Linter / pre-commit

A combination of [Prettier](https://prettier.io/),
[`markdownlint`](https://github.com/igorshubovych/markdownlint-cli),
[`yamllint`](https://github.com/adrienverge/yamllint),
[ShellCheck](https://www.shellcheck.net/),
[`shfmt`](https://github.com/mvdan/sh), and
[`hadolint`](https://github.com/hadolint/hadolint) is used via
[pre-commit](https://pre-commit.com/) to ensure consistent formatting and –
where possible – more elaborate sanity-checking.

Pre-commit is used as a convenient way of generalising linter execution; its
package management features are barely used – most of the linters in-use need to
be installed locally anyway for their respective VS Code extensions...

To set up pre-commit, follow the below instructions. This assumes a system
running Debian/Ubuntu with Node/`npm`, and Python3/`pip` already installed.

```shell
./.github/scripts/setup-pre-commit.sh
pre-commit install
```

pre-commit use used to enforce a set of formatters and linters.

## Extras

See [`📂 extras`](./extras/README.md).

## TODO

See [`📄 TODO`](./TODO).
