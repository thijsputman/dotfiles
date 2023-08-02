# `binfmt` / WSL-interop

After running with `systemd` enabled for quite some time, out of nowhere
WSL-interop stopped working 😕 Appears to be a known issue:
[microsoft/WSL#8843](https://github.com/microsoft/WSL/issues/8843#issuecomment-1255546484)
– follow the thread from there for more details...

To fix the issue, create
[`📄 /usr/lib/binfmt.d/WSLInterop.conf`](./WSLInterop.conf) as shown in this
repository and restart WSL. To check if things are now loaded properly, use the
below (or simply call `cmd.exe` 😇).

```bash
sudo ls -Fal /proc/sys/fs/binfmt_misc
sudo cat /proc/sys/fs/binfmt_misc/WSLInterop
```

I've added a check to [`📄 .bashrc.d/05-wsl`](/.bashrc.d/05-wsl) (which tests
interop by calling `cmd.exe /c ver`) as I've now spend too much time
troubleshooting the subtle and unexpected ways in which this breaks my WSL
setup...

Solution courtesy of
[https://randombytes.substack.com](https://randombytes.substack.com/i/74454696/restores-the-wslinterop-binary-format-in-case-it-is-lost-when-systemd-updates-binfmts>).
