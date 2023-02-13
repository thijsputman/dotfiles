# Unattended-upgrades

Notify (via MOTD) about available upgrades, but don't automatically install
them. This works for Ubuntu (20.04 and 22.04); on Debian the file is called
`📄 02periodic`.

**N.B.** Inspect `📄 20auto-upgrades` to ensure it doesn't conflict with the
settings applied made in `📄 10periodic`.

Test with:

```bash
sudo unattended-upgrade -d -v --dry-run
```
