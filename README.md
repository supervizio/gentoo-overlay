# supervizio — Gentoo overlay

> Written by supervizio's release pipeline. It holds no package until the first
> supervizio release published since it was created; the steps below work from then on.

A Portage repository with one package, `app-admin/supervizio-bin`: the
[supervizio](https://supervizio.github.io/agent/) process supervisor and
OpenTelemetry collector agent, from the statically linked binary each release
publishes (amd64 and arm64).

## Install

With [eselect-repository](https://wiki.gentoo.org/wiki/Eselect/Repository):

```sh
eselect repository add supervizio git https://github.com/supervizio/gentoo-overlay.git
emaint sync --repo supervizio
emerge --ask app-admin/supervizio-bin
```

Without it, `/etc/portage/repos.conf/supervizio.conf`:

```ini
[supervizio]
location = /var/db/repos/supervizio
sync-type = git
sync-uri = https://github.com/supervizio/gentoo-overlay.git
```

then `emaint sync --repo supervizio` and `emerge --ask app-admin/supervizio-bin`.

A prerelease is keyworded `~amd64`/`~arm64`; a release is stable.

## Start it

```sh
rc-update add supervizio default && rc-service supervizio start   # OpenRC
systemctl enable --now supervizio                                 # systemd
```

The configuration is `/etc/supervizio/config.yaml`, copied from
`config.example.yaml` on the first install and left alone after that.

## What the package installs

| Path | What |
|------|------|
| `/usr/bin/supervizio` | the release's binary, as published (`supervizio-linux-{amd64,arm64}-musl`), bound by the Manifest's BLAKE2B and SHA512 |
| `/etc/init.d/supervizio` | the OpenRC script every supervizio package ships |
| `/usr/lib/systemd/system/supervizio.service` | the systemd unit every supervizio package ships |
| `/etc/supervizio/config.example.yaml` | the example configuration |
| `/var/log/supervizio` | the log directory |

The binary is linked statically, so the same bytes run on a glibc or a musl
profile.

## Where this comes from

Nothing here is edited by hand. supervizio's release pipeline writes this
repository when it publishes a release, and a release is published only after
its end-to-end validation has installed this ebuild, against that release's
own binary, on Gentoo with OpenRC as PID 1 — then probed, supervised and
uninstalled it. Report problems in this repository's issues.
