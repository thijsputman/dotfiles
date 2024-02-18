# Linux' `📂 /etc`

- [WSL2 - `wsl.conf` \& `fstab`](#wsl2---wslconf--fstab)
  - [Using Microsoft's `/init`](#using-microsofts-init)
  - [`generateResolvConf`](#generateresolvconf)

## WSL2 - `wsl.conf` & `fstab`

❗ **N.B.** Copy to `📂 /etc`; do _**not**_ symlink...

- Sets up WSL2 to use `systemd`
- ~~WSL2 is instructed to _not_ create `resolv.conf`~~ – not anymore,
  [see below](#generateresolvconf)
- Interop is enabled, but no Windows directories are added to the `PATH`
  automatically
  - Instead this is done manually via
    [`📄 ~/.bashrc.d/05-wsl`](../../../.bashrc.d/05-wsl)
- Automatic mounting of Windows filesystems is _disabled_ – instead, the `C`-
  and `D`-drive are manually mounted via [`📄 /etc/fstab`](fstab)
  - This is done so the `D`-drive (`/mnt/d`) can be mounted with `fmask 111`
    (disabling the execute-bit for all users) – execute can be enabled on a
    per-file basis; the `metadata` option ensures Linux-metadata persists in
    NTFS
  - This cannot be done via a regular `[automount]`-section as it's impossible
    to differentiate between drives there – mounting the `C`-drive
    with`fmask 111` (for all intents and purposes)
    [breaks interop](https://github.com/microsoft/WSL/issues/7933).
- A default username (`thijs`) is set

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

### `generateResolvConf`

I've recently tweaked my firewall settings so that Windows' DNS properly works
in WSL2 (as I needed mDNS inside WSL2). The allows for a much more robust DNS
setup and as such there's no more need for a custom `📄 /etc/resolv.conf`.

Additionally, as of
[WSL **2.0.0**](https://github.com/microsoft/WSL/releases/tag/2.0.0) _with_
`dnsTunneling` enabled, it doesn't make sense to mess with DNS settings at all
anymore: With this option enabled, DNS isn't proxied over the network so
firewall settings don't even impact its functionality anymore.

The below is kept for reference:

---

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
