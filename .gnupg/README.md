# GPG Configuration

## `gpg.conf`

The `no-autostart` option in [`📄 gpg.conf`](gpg.conf) prevents the `gpg` binary
from auto-starting `gpg-agent` (in `--daemon` mode) – the agent should thus
either be started via other means, or should be available on a remote socket.

In WSL, GPG agent is started automatically via systemd (in `--supervised` mode),
so the setting in `📄 gpg.conf` doesn't have any adverse effects.

On the RPis, not starting GPG agent is intentional: They rely on a remote
socket; starting a local `gpg-agent` messes with that setup.
