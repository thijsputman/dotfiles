# GPG Configuration

- [`📄 gpg.conf`](#-gpgconf)
- [Yubikey-support](#yubikey-support)
  - [Background](#background)
  - [`📄 scdaemon.conf`](#-scdaemonconf)

## `📄 gpg.conf`

The `no-autostart` option in [`📄 gpg.conf`](gpg.conf) prevents the `gpg` binary
from auto-starting `gpg-agent` (in `--daemon` mode) – the agent should thus
either be started via other means, or should be available on a remote socket.

In WSL, GPG agent is started automatically via systemd (in `--supervised` mode),
so the setting in `📄 gpg.conf` doesn't have any adverse effects.

On the RPis, not starting GPG agent is intentional: They rely on a remote
socket; starting a local `gpg-agent` messes with that setup.

## Yubikey-support

As of Ubuntu 24.04 (more specifically, GnuPG 2.4), GnuPG defaults to accessing
smartcards directly (instead of through `pcscd`). This causes some issues my
Yubikey, as by default it seems it is not accessible by non-root users on
Ubuntu...

The best (and easiest) solution is to allow non-root access to your Yubikey, by
adding this udev-rule to your system:

[`📄 /etc/udev/rules.d/70-yubikey.rules`](/static/linux/etc/udev/rules.d/70-yubikey.rules)

Subsequently run the following to disable `pcscd` and apply the `udev`-rule:

```shell
# Fully disable and stop the PC/SC-daemon
sudo systemctl mask pcscd
sudo systemctl stop pcscd
# Apply the new udev-rule
sudo udevadm control --reload
sudo udevadm trigger
# Kill gpg-agent
pkill -9 gpg-agent
# You should now be able to communicate as non-root with the Yubikey via GnuPG
gpg --card-status
```

❗ **N.B.** In case you want to use the Yubikey for other purposes (such as
FIDO2 or OTP), additional `udev`-rules might be required.

### Background

See <https://blog.apdu.fr/posts/2024/04/gnupg-and-pcsc-conflicts-episode-2/> and
<https://bugs.launchpad.net/ubuntu/+source/pcsc-lite/+bug/2061708> for more
details.

A workaround is provided ("disable the integrated CCID-driver in GnuPG"), but
the linked resources also seem to indicate this is not the recommended solution.

After a bit of digging, the problem seems to be limited to a simple rights-issue
with the Yubikey being not accessible by non-root users (with `pcscd` _disabled_
the below does work):

```shell
sudo ykman info
sudo gpg --card-status
```

So, I cobbled together a better solution –
<https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=924787#10>:

```conf
SUBSYSTEMS=="usb", ATTRS{idVendor}=="1050", \
  ATTRS{idProduct}=="0113|0114|0115|0116|0120|0200|0402|0403|0406|0407|0410", \
  TAG+="uaccess", GROUP="plugdev", MODE="0660"
```

To which I appended – <https://security.stackexchange.com/a/207069>:

```conf
ENV{ID_SMARTCARD_READER}="1", ENV{ID_SMARTCARD_READER_DRIVER}="gnupg"
```

❗ **N.B.** It is not possible to remove the `pcscd`-package, as – for example –
`yubikey-manager` depends on it. You do need to disable/mask and stop the
service, as it holds an exclusive lock on the smartcard (and would thus prevent
GnuPG from accessing it directly).

Additionally, `ykman info` complains when `pcscd` is not running, but appears to
function just fine. I can imagine there are certain (temporary) scenarios where
you might need to start the PC/SC-daemon to be able to fully use `ykman`. That's
a matter of unmasking and starting it, and subsequently stopping and masking it
again...

### `📄 scdaemon.conf`

An alternative solution is to disable direct access to the smartcard by GnuPG,
and force it to use `pcscd` instead.

This can be done by adding the below to `📄 ~/.gnupg/scdaemon.conf` and using
`⚙️ pkill -9 gpg-agent` to restart your GPG-agent.

```conf
disable-ccid
pcsc-shared
```

This works fine on my system, but does generate occasional hickups when trying
to access the Yubikey. It seems this is only recommended if you really need
`pcscd` (ie, you have a use-case for shared access to your smartcard).
