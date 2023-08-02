# AppData

- [PowerShell](#powershell)
  - [`OpenVPN.ps1` Scheduled Task](#openvpnps1-scheduled-task)

## PowerShell

When PowerShell 7 is installed from the **Microsoft Store** (the preferred way
nowadays), the following path should be used to call `pwsh.exe` (it'll
automatically point to the latest/correct version):

`C:\Users\<username>\AppData\Local\Microsoft\WindowsApps\pwsh.exe`

This is primarily relevant when running PowerShell scripts from Task Scheduler
as that (seemingly) doesn't use `PATH` under all circumstances. See
[PowerShell/PowerShell#14477](https://github.com/PowerShell/PowerShell/issues/14477#issuecomment-749208123)
for some more details.

### `OpenVPN.ps1` Scheduled Task

Use the `At log on`-trigger and make sure to check
`Run whether user is logged on or not` _and_ `Do not store password` to prevent
having a Terminal window popup on your desktop.

- Program/script: `pwsh.exe`
- Add arguments:
  `-ExecutionPolicy ByPass -File "C:\Users\<username>\AppData\Local\OpenVPN.ps1"`
- Start in: **`C:\Users\<username>\AppData\Local\Microsoft\WindowsApps`**
