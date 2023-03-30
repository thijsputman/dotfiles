# Per-user `anacron`

For a workstation, `anacron` seems better suited than `cron` to schedule tasks.
Its one drawback is that `anacron` only runs as `root` (and doesn't offer a
per-user `crontab` like `cron` does). The below provides a simple solution to
running `anacron` on a per-user basis; courtesy of
<https://askubuntu.com/a/235090>.

## Installation

A `📄 anacrontab` is created on a per-user basis in `📂 ~/.anacron/etc` and
`anacron` is instructed to execute this `@hourly` using the user's regular
`crontab`.

See [`📄 install/parts.d/25-anacron-wsl`](/install/parts.d/25-anacron-wsl) for
full installation "instructions"...

## Usage

Add new tasks to `📄 ~/.anacron/etc/anacrontab`. Note that you should use
absolute paths (just as in a regular `crontab`) and instead of `@daily` and
`@weekly`, use `1` and `7` respectively — only the `@monthly` macro is still
allowed in the `anacrontab`...

`📂 ~/.anacron/spool` Contains timestamp files for each task executed
(indicating when the task was last run). For further debugging, use:

```shell
journalctl -b -u cron
```

Note the usage of the **`cron`** unit and _not_ the `anacron` unit (as it is `cron`
that actually executes — and captures the output of — `anacron`).
