# Linux' `📂 /etc`

- [WSL2](#wsl2)
  - [`wsl.conf` \& `fstab`](#wslconf--fstab)
  - [`nftables.conf`](#nftablesconf)

## WSL2

### `wsl.conf` & `fstab`

❗ **N.B.** Copy to `📂 /etc`; do _**not**_ symlink...

- Sets up WSL2 to use `systemd`
- ~~WSL2 is instructed to _not_ create `resolv.conf`~~ – not anymore,
  [see below](#generateresolvconf)
- Interop is enabled, but no Windows directories are added to the `PATH`
  automatically
  - Instead this is done manually via
    [`📄 ~/.profile.d/01-path-wsl`](../../../.profile.d/01-path-wsl)
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

#### Using Microsoft's `/init`

When running WSL2 using Microsoft's `/init` system instead, a handful of
services need to be automatically started. Update the `[boot]`-section to match
the below:

**`📄 /etc/wsl.conf`**

```conf
[boot]
systemd=false
command=service rsyslog start && service dbus start && service cron start && service anacron start
```

#### `generateResolvConf`

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

### `nftables.conf`

With
[Mirrored-mode networking](https://learn.microsoft.com/en-us/windows/wsl/networking#mirrored-mode-networking)
enabled, WSL2 seems to fully "bypasses" the Windows Filtering Platform (ie,
[simplewall](https://github.com/henrypp/simplewall)), effectively connecting
itself to the network **without** _any_ filtering...

A firewall thus needs to be enabled _inside_ WSL2.

The [`📄 nftables.conf`](./nftables.conf) provides a sane default for a
workstation; it's based on a combination of
[Gentoo's](https://wiki.gentoo.org/wiki/Nftables/Examples#Typical_workstation_.28separate_IPv4_and_IPv6.29)
and [Arch's](https://wiki.archlinux.org/title/Nftables#Workstation) typical
workstation configurations.

❗**N.B.** After copying (relevant parts of) the file to
`📄 /etc/nftables.conf`, run `sudo systemctl enable --now nftables` to ensure
`nftables` is enabled.

The only (substantial) addition to the typical configuration is to allow
incoming (IPv4) DNS-traffic. This is somehow required for containers running via
the (Ubuntu-native) Docker-daemon to be able to access DNS. As of yet unclear
exactly why, but probably related to WSL2's DNS-tunneling feature...

Related to this, a workaround for
[an issue in WSL2](https://github.com/microsoft/WSL/issues/10494) when using
Mirrored-mode networking in combination with the Docker-daemon is provided in
[`📄 systemd/system/network-mirrored.service`](./systemd/system/network-mirrored.service).

Once copied into place, reload `systemd` manager configuration and enable the
workaround:

```shell
sudo systemctl daemon-reload
sudo systemctl enable --now network-mirrored
```
