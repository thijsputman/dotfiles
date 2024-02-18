# Windows' `📂 %USERPROFILE%`

- [`.wslconfig`](#wslconfig)
  - [Caveats](#caveats)
- [SSH](#ssh)
  - [ProxyJump](#proxyjump)
- [Move WSL2's VHDX-files](#move-wsl2s-vhdx-files)

## `.wslconfig`

This configuration requires
[WSL **2.0.5**](https://github.com/microsoft/WSL/releases/tag/2.0.5)+ in
_combination_ with **Windows 11 23H2**.

- Enables `mirrored` networking-mode, DNS tunneling and Hyper-V firewall support
- Sets automatic memory reclamation to `gradual`
- Enables sparse VHDXs for new WSL2-instances
  - In case of an existing WLS-instance:
    `wsl --manage <distro> --set-sparse true`

For more details on these options, see:
<https://devblogs.microsoft.com/commandline/windows-subsystem-for-linux-september-2023-update/>.

### Caveats

#### Hyper-V firewall

_Without_ Hyper-V firewall support (the only option available pre-`2.0.0`), the
`SharedAccess`-service on the Windows-side needs to be allowed through
[Simplewall](https://github.com/henrypp/simplewall) for WSL2 to have
(_unrestricted_) network access. The (post-`2.0.0`) firewall support offers a
far superior solution which doesn't require this blanket exception.

#### `mirrored` Networking-mode

Enabling `mirrored` networking-mode will cause ports to be shared between
Windows and WSL2 which might cause issues with certain services (e.g. `sshd`).
Disable either one, or move one to a different port – optionally use
[`experimental.ignoredPorts`](https://learn.microsoft.com/en-us/windows/wsl/wsl-config#experimental-configuration-settings)
to exclude the port on the WSL2-side (making that service only available inside
WSL2 itself).

With regards to `sshd`, it's probably wisest to disable/remove the service
altogether on WSL2 as I never use it there anyway... I do have the OpenSSH SSH
Service enabled on the Windows-side so I can
[`ProxyJump` through it](#proxyjump) to workaround some
[OpenVPN-related issues in WSL2](https://github.com/microsoft/WSL/issues/10879#issuecomment-1854559320).

#### Sparse VHDX

After enabling the sparse VHDX functionality, the reported `Size` of the
VHDX-file in Windows doesn't change. Instead, look at `Size on disk` (in the
"Properties"-tab) to see the actual impact. Sparse VHDX appears to be
implemented as part of SSD trim, so it won't work if the disk image is stored on
a mechanical drive...

On the Linux-side, you might need to trim the drive and/or enable trim-support
to actually release unused disk space:

```shell
sudo fstrim -v /
```

On Ubuntu 22.04, the weekly timer running trim (`fstrim.timer`) is disabled when
running inside an container (ie, WSL2). To enable it for WSL2, run
`sudo systemctl edit fstrim.timer` and add the following override:

```conf
[Unit]
ConditionVirtualization=
ConditionVirtualization=wsl
```

## SSH

Install [OpenSSH for Windows32](https://github.com/powershell/Win32-OpenSSH):

```powershell
winget install Microsoft.OpenSSH.Beta
```

Subsequently copy `📄 ~/.ssh/config` and `📄 .ssh/id_rsa_yubikey.pub` from
Ubuntu into Windows' `📂 %USERPROFILE%\.ssh` folder – alternatively, use the
Windows-specific copy of the SSH configuration kept in OneDrive.

See [`📄 yubikey/README.md`](/extras/yubikey/README.md#windows) for more
details.

### ProxyJump

To workaround some
[OpenVPN-related issues in WSL2](https://github.com/microsoft/WSL/issues/10879#issuecomment-1854559320),
use `ProxyJump` to jump through `localhost` (ie, the OpenSSH server running on
Windows) to a target machine inside the OpenVPN accessible network:

```shell
ssh -J localhost [target-machine]
```

For this to work, ensure your SSH-key is added to
`📄 %PROGRAMDATA%\ssh\administrators_authorized_keys` – as that is where
Windows' OpenSSH server looks for them... See <https://superuser.com/a/1651276>
for more details.

## Move WSL2's VHDX-files

By default, WSL2's VHDX-files are stored somewhere in `%APPDATA%`. To move them
(to another drive), do something along the lines of:

```powershell
wsl --shutdown
wsl --export Ubuntu D:\Temp\ubuntu.vhdx --vhd
wsl --unregister Ubuntu
wsl --import Ubuntu D:\wslStore\Ubuntu D:\Temp\ubuntu.vhdx --version 2 --vhd
```

❗ **N.B.** First update [`📄 /etc/wsl.conf`](../linux/etc/README.md) as
otherwise the default user gets lost (and Ubuntu will use `root` instead).
