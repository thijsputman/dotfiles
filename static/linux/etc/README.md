# Linux `📂 /etc`

## WSL2 `📄 wsl.conf` & `📄 resolv.conf`

❗ **N.B.** Copy these files to `📂 /etc`; do _**not**_ symlink them...

### `📄 wsl.conf`

- WSL2 is instructed to _not_ create `resolv.conf` (instead it is manually
  added, see below)
- Interop is enabled, but no Windows directories are added to the `PATH`
  automatically (this is done manually via
  [`📄 ~/.bashrc.d/05-wsl`](../../../.bashrc.d/05-wsl))
- A default username is set

Alternatively, use `📄 wsl.init.conf` (rename it to `📄 wsl.conf`) when running
WSL2 using Microsoft's `/init` system. In this case, a handful of services are
automatically started via the WSL configuration.

### `📄 resolv.conf`

As of the initial Windows 11 release (21H2; build `22000.194`) there appears to
be an issues which causes WSL2 to delete `📄 /etc/resolv.conf` at boot – see
<https://github.com/microsoft/WSL/issues/5420> for details.

To work around this issue, ensure the modified `📄 resolv.conf` is immutable:
`sudo chattr +i /etc/resolv.conf`. You might need to remove and recreate
`📄 /etc/resolv.conf` first (as the file created by WSL2 doesn't allow `chattr`
to be run against it).
