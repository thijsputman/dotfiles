# `unattended-upgrades`

Installed by default on Ubuntu; for Debian/RPi OS:

```shell
apt install unattended-upgrades apt-config-auto-update
apt install needrestart # optional, for restart/outdated-binaries notification
```

## Disable automatic upgrade

Notify (via MoTD) about available upgrades, but don't automatically download or
install anything. Based on Ubuntu's (20.04 / 22.04) default configuration; on
RPi OS/Debian the file was called `📄 02periodic`; more recent versions (with
`apt-config-auto-update` installed) use `📄 10periodic` as Ubuntu does.

**N.B.** Inspect `📄 20auto-upgrades` to ensure it doesn't conflict with the
settings applied in `📄 10periodic` (mainly ensure
`APT::Periodic::Unattended-Upgrade "0"`).

Test with:

```bash
sudo unattended-upgrade -d -v --dry-run
```
