# `📂 apt.conf.d`

❗ **N.B.** This procedure is automated by
[`📄 install/parts.d/90-auto-upgrades`](/install/parts.d/90-auto-upgrades).

## Disable automatic upgrade

Notify (via MOTD) about available upgrades, but don't automatically download or
install anything.

Based on Ubuntu's default configuration – on RPi OS/Debian the file used to be
called `📄 02periodic`; more recent versions (with `apt-config-auto-update`
installed) use `📄 10periodic` as Ubuntu does.

**N.B.** Inspect `📄 20auto-upgrades` to ensure it doesn't conflict with the
settings applied in `📄 10periodic` (mainly ensure
`APT::Periodic::Unattended-Upgrade "0";`).

Test with:

```bash
sudo unattended-upgrade -d -v --dry-run
```
