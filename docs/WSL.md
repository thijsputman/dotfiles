# WSL

## Vagrant on WSL

In a nutshell: Install Vagrant both on Windows and on WSL (ensure both have
_exactly_ the same version). Use `VAGRANT_WSL_ENABLE_WINDOWS_ACCESS` to toggle
the support on in Vagrant on WLS and ensure Windows VirtualBox is available on
the WSL `PATH`.

Detailed instructions here: https://www.vagrantup.com/docs/other/wsl.html.

**N.B.**: Skip the nonsense with regards to setting
`VAGRANT_WSL_WINDOWS_ACCESS_USER_HOME_PATH` for SSH to work. A much better
workaround is possible through enabling metadata in DrvFs (see below).

## Mounting DrvFs with custom options _and_ metadata

Exact settings are in [`wsl.conf`](../wsl.conf).

More details here:
https://devblogs.microsoft.com/commandline/automatically-configuring-wsl/.

### `umask` & `fmask`

Setting `umask` to `22` makes files & folders in DrvFs _without_ explicit
metadata (see below) writable only by the default WSL user (`chmod 0775`)
&ndash; seems more sensible than keeping them world-writable. This has the added
benefit of preventing Ruby (in Vagrant) from complaining about the fact the
folders on the `PATH` are world- writable...

Setting `fmask` to `11` removes the `+x` flag from all files (again only those
_without_ explicit metadata) for everyone _except_ the default WLS user. Ideally
one would also remove `+x` for that user (and only manually set it when/where
needed), but that causes a host of problems on WSL:

- Windows executables in the mounted drives (i.e. `C:\`) are not automatically
  marked as such &ndash; completely breaking the Windows interoperability (with
  no apparent nice solution, see ... and ...)
- Most current software "with WSL support" (such as VS Code) doesn't count on
  this settings and thus also breaks down in creative ways...

There's a lively discussion on WSL's GitHub pages with regards to the above and
the (obvious) caveats. See for example
https://github.com/microsoft/WSL/issues/4778 and
https://github.com/microsoft/WSL/issues/3267. I guess for now it's best to
simply accept the above as the status quo 🙂

### Metadata

Enables the use of `chmod` on the mounted volumes &ndash; which is useful in
some cases (such as Vagrant and its use of private SSH-keys that need to have
`chmod 0600` for it to work).

There are some caveats and in general (due to the fact that the drives are in
active use on the Windows-side) one should not rely on the metadata too much
&ndash; editting files on the Windows side can for example easily nuke the WSL
metadata.

More details here:
https://devblogs.microsoft.com/commandline/chmod-chown-wsl-improvements/.

#### Git and DrvFs metadata

There is one more substantial issue: With the above, Git will start thinking the
filesystem has proper filemode-support and it will start checking in the `+x`
mode on each and every file (as by default every file has mode `+x` set _and_ we
cannot rely on our `-x` metadata to "stick" as files are like also modified from
the Windows-side from time to time). Checking in files with mode `+x` is
something we don't want; it has downstream security implications.

Git can easily be configured to not do this:
https://git-scm.com/docs/git-config#Documentation/git-config.txt-corefileMode,
but this only works on a per-repository basis as `git init` and `git clone` are
hardcoded to set `core.fileMode` to what they deem is best. In the "DrvFs with
metadata" scenario their judgement is sadly invalid...

See the `git`-function in [`.bash_aliases`](../.bash_aliases) for the most
elegant workaround I could devise around this issue: It intercepts `git clone`
and automatically follows up with an appropriate `git configure`; it intercepts
`git init` and appends the correct `--configure` argument to it.
