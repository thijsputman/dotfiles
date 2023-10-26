# Linux `📂 /etc`

- [WSL2 - `wsl.conf`](#wsl2---wslconf)
  - [Using Microsoft's `/init`](#using-microsofts-init)
  - [`generateResolvConf`](#generateresolvconf)

## WSL2 - `wsl.conf`

❗ **N.B.** Copy to `📂 /etc`; do _**not**_ symlink...

- Sets up WSL2 to use `systemd`
- ~~WSL2 is instructed to _not_ create `resolv.conf`~~ – not anymore,
  [see below](#generateresolvconf)
- Interop is enabled, but no Windows directories are added to the `PATH`
  automatically
  - Instead this is done manually via
    [`📄 ~/.bashrc.d/05-wsl`](../../../.bashrc.d/05-wsl)
- A default username is set

### Using Microsoft's `/init`

When running WSL2 using Microsoft's `/init` system instead, a handful of
services need to be automatically started. Update the `[boot]`-section to match
the below:

**`📄 /etc/wsl.conf`**

```conf
[boot]
systemd=false
command=service rsyslog start && service dbus start && service cron start && service anacron start
```

Also note that in this scenario,
[`📄 ~/.bashrc.d/30-x11-wsl`](../../../.bashrc.d/30-x11-wsl) should be enabled
(`chmod +x`).

### `generateResolvConf`

I've recently tweaked my firewall settings so that Windows' DNS properly works
in WSL2 (as I needed mDNS inside WSL2). The allows for a much more robust DNS
setup and as such there's no more need for a custom `📄 /etc/resolv.conf`.

The below is kept for future reference:

**`📄 /etc/resolv.conf`**

```conf
search sgraastra
nameserver 192.168.x.x
```

As of the initial Windows 11 release (21H2; build `22000.194`) there appears to
be an issues which causes WSL2 to delete `📄 /etc/resolv.conf` at boot – see
<https://github.com/microsoft/WSL/issues/5420> for details.

To work around this issue, ensure the modified `📄 resolv.conf` is immutable:
`sudo chattr +i /etc/resolv.conf`. You might need to remove and recreate
`📄 /etc/resolv.conf` first (as the file created by WSL2 doesn't allow `chattr`
to be run against it).
