# Using Yubikey for GPG & SSH

Based upon <https://github.com/drduh/YubiKey-Guide>

- [Setup Docker](#setup-docker)
  - [Check the Yubikey](#check-the-yubikey)
  - [Setup GnuPG home](#setup-gnupg-home)
- [Generate GPG keys](#generate-gpg-keys)
  - [Lint GPG keys](#lint-gpg-keys)
  - [Create backup](#create-backup)
  - [Exfiltrate keys](#exfiltrate-keys)
- [Setup the Yubikey](#setup-the-yubikey)
  - [Prepare the Yubikey](#prepare-the-yubikey)
  - [Move GPG keys to the Yubikey](#move-gpg-keys-to-the-yubikey)
- [Clean-up](#clean-up)
  - [Delete backup](#delete-backup)
  - [Delete secret key](#delete-secret-key)
  - [Delete GnuPG home](#delete-gnupg-home)
- [Usage](#usage)
  - [Linux (generic)](#linux-generic)
  - [Windows](#windows)
  - [WSL2](#wsl2)
- [Restore from Backup](#restore-from-backup)
  - [Renew Subkeys](#renew-subkeys)
  - [Revoke the Master key](#revoke-the-master-key)

## Setup Docker

Create an ephemeral Docker container (with all required prerequisites installed
— see [`📄 Dockerfile`](./Dockerfile)) and start it without network access:

```bash
docker run --network none --privileged -v /dev/bus/usb:/dev/bus/usb \
  --rm -it $(docker build --no-cache -q .)
```

**N.B.** Stop `pcscd` (and/or anything else that might have an exclusive lock on
the Yubikey) on the host machine before attempting to start `pcscd` in the
container...

The Docker container is used purely out of convenience (an easy way to tool up a
clean/prepared environment). From a security perspective there is little benefit
in doing things this way. Also, I'm moving an unencrypted backup of the master
key (protected with its passphrase though) around on my daily-use machine. If
you're truly concerned about security, best to not follow the below set of
instructions...

### Check the Yubikey

```bash
pcscd
ykman info
```

### Setup GnuPG home

```bash
export GNUPGHOME=$(mktemp -d -t gnupg_$(date +%Y%m%d%H%M)_XXX)
cp ~/gpg.conf $GNUPGHOME/gpg.conf
cp ~/gen-params-ed25519.conf $GNUPGHOME/gen-params-ed25519.conf

# Add real name and e-mail address to configuration
sed -i '/^Name-Real:/s/:/: ______/g' $GNUPGHOME/gen-params-ed25519.conf
sed -i '/^Name-Email:/s/:/: ______/g' $GNUPGHOME/gen-params-ed25519.conf
```

## Generate GPG keys

```bash
gpg --gen-random --armor 0 32
# Take note of the master key's passphrase; store it in KeePass

gpg --batch --generate-key $GNUPGHOME/gen-params-ed25519.conf
gpg -K

# Export master key fingerprint and ID for later use
export KEYFP="______"
export KEYID=0x______

gpg --quick-add-key "$KEYFP" ed25519 sign 1y
gpg --quick-add-key "$KEYFP" cv25519 encrypt 1y
gpg --quick-add-key "$KEYFP" ed25519 auth 1y

# Add as many UIDs (i.e., e-mail addresses) as required
gpg --expert --edit-key $KEYID
> adduid
> ...
> uid 2 # select UID 2
> trust
>> 5
> uid 2 # deselect UID 2
> ... # Add more UIDs
> uid 1 # select UID 1
> primary
> save
```

A dot (`.`) behind the UID indicates it's the primary UID; an asterisk (`*`)
indicates the UID is active/selected.

### Lint GPG keys

```bash
gpg --export $KEYID | hokey lint
```

> hokey may warn (orange text) about cross certification for the authentication
> key. GPG's Signing Subkey Cross-Certification documentation has more detail on
> cross certification, and gpg v2.2.1 notes "subkey does not sign and so does
> not need to be cross-certified". hokey may also indicate a problem (red text)
> with Key expiration times: [] on the primary key (see Note #3 about not
> setting an expiry for the primary key).
>
> <https://github.com/drduh/YubiKey-Guide#notes>

### Create backup

```bash
mkdir ~/backup
gpg --armor --export-secret-keys $KEYID > ~/backup/mastersub.key
gpg --export-secret-keys $KEYID | paperkey --output ~/backup/master-paperkey.txt
gpg --armor --export-secret-subkeys $KEYID > ~/backup/sub.key
gpg --output ~/backup/revoke.asc --gen-revoke $KEYID
tar -cf - -C $GNUPGHOME . > ~/backup/.gnupg.tar
```

**N.B.** When printing the paperkey, note down the master key's passphrase on
the piece of paper too.

#### Export Public key

```bash
gpg --armor --export $KEYID > ~/gpg-$KEYID-$(date +%F).asc
echo "/root/gpg-$KEYID-$(date +%F).asc"
# Take note of the public key filename
```

### Exfiltrate keys

From the host machine:

```bash
docker ps
# Public key
docker cp ______:/root/gpg-0x______.asc ~/
# Private keys & revocation certificate
docker cp ______:/root/backup/mastersub.key ~/
docker cp ______:/root/backup/master-paperkey.txt ~/
docker cp ______:/root/backup/sub.key ~/
docker cp ______:/root/backup/revoke.asc ~/
# GnuPG home-directory
docker cp ______:/root/backup/.gnupg.tar ~/
```

Once exfiltrated, store `📄 .gnupg.tar` in KeePass and remove it from the host
machine.

## Setup the Yubikey

### Prepare the Yubikey

**N.B.** Check `ykman --version`. It should be **version 4** for the below
commands to work as intended (and for a _non-numeric_ **Admin PIN** to be
allowed for OpenPGP).

```bash
ykman openpgp reset
gpg --gen-random --armor 0 32
# Take note of the Yubikey OpenPGP Admin PIN; store it in KeePass

gpg --card-edit
> admin
> kdf-setup
> passwd
>> 3
>> 1
>> q
> name
>> ...
> salutation
>> ...
> login
>> ...
> lang
>> en
> quit
```

```bash
ykman openpgp access set-retries 3 3 5
```

Due to the complexity of the **Admin PIN**, 5 retries seems prudent.

**N.B.** The **Reset PIN** isn't necessary for personal use. It's only function
is to reset the regular PIN (which is also possible with the **Admin PIN**) —
mainly intended for enterprise scenarios.

### Move GPG keys to the Yubikey

```bash
gpg --edit-key $KEYID
> key 1 # select key 1
> keytocard
>> 1 # signature key
> key 1 # deselect key 1
> key 2
> keytocard
>> 2 # encryption key
> key 2
> key 3
> keytocard
>> 3 # authentication key
> save
gpg --card-status
```

The `>` (in `ssb>`) indicates they key has been moved to card...

Finally, enforce "touch" for all the keys (configuration is reset when keys are
changed):

```bash
ykman openpgp keys set-touch aut fixed
ykman openpgp keys set-touch sig fixed
ykman openpgp keys set-touch enc fixed
```

## Clean-up

### Delete backup

```bash
rm -rf ~/backup
```

### Delete secret key

```bash
gpg --delete-secret-key $KEYID
gpg --card-status
```

The `#` (in `sec#`) Indicates master key is not available anymore...

### Delete GnuPG home

```bash
rm -rf $GNUPGHOME
export GNUPGHOME=$(mktemp -d -t gnupg_$(date +%Y%m%d%H%M)_XXX)
gpg -K
# *empty*
gpg --card-status
# General key info..: [none]
```

**N.B.** `gpg -k` and `gpg -K` provide different outputs (the former also shows
revoked and expired keys).

## Usage

### Linux (generic)

Import the key on each machine where you want to use it:

```bash
gpg --import ~/gpg-0x\*.asc
gpg --edit-key ______
```

I personally only have it imported on my daily driver; using SSH agent
forwarding to forward both the SSH and GPG agents to (trusted) remote machines.

❗ **N.B.** After [renewing my subkeys](#renew-subkeys), I had to import the
(updated) public key on a handful of additional machines for them to pick up on
the updated expiry dates. Haven't had the time to properly figure this out yet;
in case I never do: The simplest solution is to import the updated public key on
the offending machine...

_Optional:_ Save public key (from Yubikey) for identity file configuration.
Mainly useful to explicitly configure a connection to use the Yubikey (via
[`📄 ~/.ssh/config`](../../static/linux/home/.ssh/config)).

```bash
ssh-add -L | grep "cardno:000______" > ~/.ssh/id_rsa_yubikey.pub
```

See [`📄 ~/.ssh/config`](../../static/linux/home/.ssh/config) for more details.

### Windows

On the windows-side install the following to use the Yubikey for SSH operations:

- [Microsoft OpenSSH](https://github.com/PowerShell/Win32-OpenSSH) (from GitHub)
- [GnuPG (win32)](https://www.gnupg.org/ftp/gcrypt/binary/gnupg-w32-2.4.0_20221216.exe)
  — _don't_ install Gpg4win; the basic binaries distributed directly by GnuPG
  suffice...
  - Use [`run-hidden`](https://github.com/stax76/run-hidden) in combination with
    _Task Scheduler_ to run the agent at logon: `run-hidden gpg-agent --daemon`
- [wsl-ssh-pageant](https://github.com/benpye/wsl-ssh-pageant)
  - Use _Task Scheduler_ to run the `wsl-ssh-pageant` at logon:
    `wsl-ssh-pageant-gui.exe --winssh ssh-pageant`
  - Set `SSH_AUTH_SOCK=\\.\pipe\ssh-pageant` in your Windows (user) environment

This should allow SSH connections to be authenticated via Windows' OpenSSH
through the Yubikey. A GnuPG window will popup asking for the Yubikey PIN.
Haven't tried/bothered to get GPG signing up-and-running; using WSL2 (see below)
for that.

### WSL2

To allow the Yubikey to be used from within WSL2, install
**[`usbipd-win`](https://github.com/dorssel/usbipd-win)**.

On the WSL2-side:

```shell
sudo apt install linux-tools-virtual hwdata
sudo update-alternatives --install /usr/local/bin/usbip usbip \
  "$(ls /usr/lib/linux-tools/*/usbip | tail -n1)" 20
```

**N.B.** If `linux-tools-virtual` gets updated, it might be necessary to reapply
the `update-alternatives` for `usbip`.

The Yubikey needs to be bound on the Windows-side once before it can be used.
From an _elevated_ PowerShell-prompt run:

```powershell
usbipd bind -b ...
```

Afterwards, attaching and detaching the Yubikey is done in WSL2 via two
convenience commands provided in `📂 .bashrc.d`:

```bash
yubikey-attach
yubikey-detach # Alternatively, physically detach and reattach the key...
```

The most common commands requiring the Yubikey to be attached (`git` and `ssh`)
are wrapped with an automatic `yubikey-attach`. For maximum flexibility, ensure
**WSLg** is properly configured so that a GUI `pinentry` dialogue can be
shown...

The main functionality is provided by
[`📄 ~/.bashrc.d/40-gpg-yubikey-wsl`](../../.bashrc.d/40-gpg-yubikey-wsl) — see
that script for more details.

To prevent relentless `sudo`-prompts, update your configuration with the
following:
[`📄 /etc/sudoers.d/80-yubikey`](../../static/linux/etc/sudoers.d/80-yubikey)
(`sudo visudo -f /etc/sudoers.d/80-yubikey`).

Additional convenience for using the Yubikey via SSH on remote machines is
provided through
[`📄 ~/.bashrc.d/41-ssh-remote-rpi`](../../.bashrc.d/41-ssh-remote-rpi).

#### Fixed IP address / Firewall

❗**N.B.** As of
[WSL **2.0.0**](https://github.com/microsoft/WSL/releases/tag/2.0.0) (in
_combination_ with **Windows 11 23H2**), the below is not required anymore as
long as `networkingMode` is set to `mirrored` (see
[`📄 .wslconfig`](/static/windows/README.md) for more details).

Using the `mirrored` networking-mode, the `usbipd`-service on the Windows-side
can be reached reliably (and securely) via `127.0.0.1` from _within_ WSL –
there's no more need for firewall exceptions and such...

Should you still wish to use the below approach, take note of the fact that
(most likely) WSL's vEthernet-adapter is called
`vEthernet (WSL (Hyper-V firewall))` instead of `vEthernet (WSL)`. Apart from
that, the procedure below still works just fine (although using mirrored
networking-mode offers a far superior solution).

---

To allow for a fixed firewall exception (not relying on either the local network
or the network dynamically created by Hyper-V), a special-purpose fixed IP
address is attached to the WSL2-instance's `vEthernet (WSL)` adapter:

```cmd
netsh interface ip add address "vEthernet (WSL)" 192.168.___.1 255.255.255.0
netsh interface ip delete address "vEthernet (WSL)" 192.168.___.1
```

As these commands require elevation on the Windows-side, they are run via _Task
Scheduler_ (so as to not have to manually elevate whenever the command is
executed). Create a trigger-less task named **WSL2 fixed IP** that runs whether
logged in or not, does _not_ store password, and runs with highest privileges:

```cmd
netsh.exe interface ip add address "vEthernet (WSL)" 192.168.___.1 255.255.255.0
```

Test the task can be executed without requiring elevation:

```cmd
schtasks.exe /run /tn "WSL2 fixed IP"
```

On this Linux-side, use the following for testing:

```bash
sudo ip addr add 192.168.___.2/24 broadcast 192.168.___.255 dev eth0 label eth0:1
sudo ip addr del 192.168.___.2/24 dev eth0:1
```

Once the interface is up you should be able to ping across it from both sides
(note that you're pinging from `.1` to `.2` and vice versa).

As `ip addr` requires root privileges on the Linux-side too, the easiest
solution is to run the whole thing `@reboot` using root's `cron`. Use
`sudo crontab -e` to setup the root's crontab as follows:

```bash
@reboot /usr/bin/ip addr add 192.168.___.2/24 broadcast 192.168.___.255 dev eth0 label eth0:1
@reboot /mnt/c/Windows/System32/schtasks.exe /run /tn "WSL2 fixed IP"
```

Concept inspired by:
<https://gist.github.com/wllmsash/1636b86eed45e4024fb9b7ecd25378ce>.

## Restore from Backup

Copy `📄 .gnupg.tar` from backup (i.e., KeePass) into an empty Docker container.

From the host machine:

```bash
docker ps
docker cp ~/.gnupg.tar ______:/root/.gnupg.tar
```

In the container:

```bash
export GNUPGHOME=$(mktemp -d -t gnupg_$(date +%Y%m%d%H%M)_XXX)
tar xf ~/.gnupg.tar -C $GNUPGHOME
rm ~/.gnupg.tar

gpg -K
export KEYID=0x______
gpg --expert --edit-key $KEYID
# Secret key is available
```

### Renew Subkeys

Update expiry of all public keys to a new (future) date:

```bash
gpg --edit-key $KEYID
> key 1
> key 2
> key 3 # select all keys
> expire
>> ...
> save
```

Export the (updated) public key and (re)import it in all places where it's used
(similar to the initial procedure — see [Exfiltrate keys](#exfiltrate-keys) and
[Usage](#usage) for instructions).

[Update the backup](#create-backup). Note that the private keys and the
revocation certificate don't change, so creating up an updated copy of
`📄 .gnupg.tar` suffices. Finally, do a [clean-up](#clean-up).

### Revoke the Master key

Using the previously generate `📄 revoke.asc`-certificate:

```bash
gpg --output revoke.asc --gen-revoke key-ID
gpg --import revoke.asc
```
