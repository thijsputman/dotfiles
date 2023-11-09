# Windows' `📂 %USERPROFILE%`

## WSL2 - `.wslconfig`

This configuration requires
[WSL **2.0.5**](https://github.com/microsoft/WSL/releases/tag/2.0.5) (or higher)
in _combination_ with **Windows 11 23H2**.

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
Windows and WSL2 which might cause issues with certain services (e.g. SSHd).
Disable either one, or move one to a different port – optionally use
[`experimental.ignoredPorts`](https://learn.microsoft.com/en-us/windows/wsl/wsl-config#experimental-configuration-settings)
to exclude the port on the WSL2-side (making that service only available inside
WSL2 itself).

With regards to SSHd, it's probably wisest to disable the service altogether on
both Windows and WSL2 as I never remotely access my laptop...

#### Sparse VHDX

After enabling the sparse VHDX functionality, the reported `Size` of the
VHDX-file in Windows doesn't change. Instead, look at `Size on disk` (in the
Properties-tab) to see the actual impact. Sparse VHDX appears to be implemented
as part of SSD trim, so it won't work if the disk image is stored on a
mechanical drive...

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
