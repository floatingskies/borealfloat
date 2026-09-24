# Borealis

![bluebuild build badge](https://github.com/floatingskies/borealis/actions/workflows/build-daily.yml/badge.svg)

Borealis is my personal remix of [Aurora DX](https://ublue-os.github.io/#aurora),
the KDE Plasma based image from [Universal Blue](https://universal-blue.org),
put together with [BlueBuild](https://blue-build.org).

I made this because I like to tinker, but I am tired of breaking my own laptop.
Aurora is amazing out of the box, so this project is a thin layer on top of it:
a handful of small files that add my favorite defaults, tune KDE to feel fast on
older hardware, and otherwise stay out of the way. It is built entirely with the
same tooling Universal Blue uses, so it stays compatible with the whole uBlue
ecosystem (ujust, Secure Boot, bootc, the works) and who is doing the maintenance
is obvious from reading the repo.

The guiding priorities, in order, are:

1. **Stability.** Nothing in this repo may break a booted system. No build step
   depends on a URL at runtime, no script touches your data or your bootloader,
   and every script fails loudly instead of quietly half working.
2. **Ease of use.** The defaults are meant so that someone who never opened a
   terminal (yes, including my mom) can install it and just use it.
3. **Universal Blue parity.** The build and ISO scripts are the same ones shipped
   for Aurora and Bazzite, so nothing here is a black box.
4. **Easy to maintain.** Every feature is a small, self documented file. A future
   maintainer can see exactly what each piece does. More on that in the
   maintenance section.

## What is baked in

The desktop wallpaper is `snowy husklamute.jpg`, from the `Auveiss-Modified`
collection that ships inside the image. It shows up exactly once on first login,
so you can change it freely afterwards, and the same artwork is used on the
login screen, so you never see the base Aurora wallpaper during boot. The
`Auveiss-Modified` and `Nature` collections are baked into the image with no
build time downloads and show up in the normal Plasma wallpaper picker. I
deliberately removed the Ubuntu, System76 and Framework wallpaper packs that the
fork this started from shipped.

Firefox is the browser, installed as an RPM, and the interface font defaults to
Intel One Mono, matching [Floatfin](https://github.com/floatingskies/floatfin)
so both images feel related. Steam comes from the negativo17 repo but never
autostarts.

A few KDE tweaks make Plasma feel snappier on old hardware: KWin runs on the
OpenGL core profile and animations run at half speed, while blur and shadows
are kept so it still looks pretty. Every value is a normal System Settings
override, nothing is locked down.

The shell greeting on login shows a small built-in fastfetch with a Borealis
logo instead of Aurora's welcome banner. Branding shows up in Settings, where
it says Borealis and points at this repository. Docker and Tailscale stay
disabled by default, as does Starship.

System sounds are the classic Borealis theme from 2004, by Ivica Ico Bukvic,
the most downloaded sound theme in KDE history and the one MX Linux made
famous. It is set as the default in System Settings, so the login and logout
chimes and the desktop notifications all play it. The theme ships in the
image, so nothing is downloaded when it plays.

The image also carries a docker-ops style CLI toolkit comparable to what the
plain Aurora DX offers: gh, ansible-core, git-lfs, jq, ripgrep, fzf, btop, htop,
tmux, nodejs, python, and a few more. Nothing exotic, just handy.

Finally, two Flatpaks, Flatseal and VLC, install themselves automatically on
first boot (see below). This happens in the background and never delays the
desktop, even with a slow or missing connection, and a small notification tells
you when they are ready.

## The image

The image is an overlay on Aurora DX following its image channels.

`ghcr.io/floatingskies/borealis:stable` tracks Aurora's stable stream and is
rebuilt weekly on Tuesdays. `ghcr.io/floatingskies/borealis:latest` tracks
Aurora's latest stream and is rebuilt daily.

## Installing

Install any Fedora Atomic edition first (Kinoite is the easiest match) and then
switch with one command:

```
sudo bootc switch ghcr.io/floatingskies/borealis:latest --enforce-container-sigpolicy
systemctl reboot
```

That is the whole installer. Updates happen automatically in the background from
then on.

Newer users will find it easier to grab the live ISO from the
[Releases](https://github.com/floatingskies/borealis/releases) page, boot it
from a USB stick, and pick Install to Disk. The Anaconda installer offers to
enroll the Universal Blue Secure Boot key along the way. Those ISOs are built
on demand by the Build Live ISOs workflow using the same installer toolchain
as Universal Blue's own images, and end up published with the checksums, the
cosign signature and the provenance attestation attached.

If you have podman on some other machine and do not want to wait on CI, this
creates an offline install ISO locally:

```
./download-iso.sh borealis stable
```

## Building locally

```
./build-image.sh borealis-stable.yml
```

This is the shared BlueBuild script from the Universal Blue templates, so
either the recipe file or its short name works. You need the bluebuild CLI
(`curl --proto '=https' --tlsv1.2 -sSf https://sh.blue-build.org | sh`).

## Verifying

The images are signed with cosign. The public key sits at `cosign.pub` in the
repo, and the live ISOs carry the signature and attestation files. cosign
verify with the key if you care about that kind of thing.

## How the repo is laid out

The recipes folder holds the two channel files, `borealis-latest.yml` and
`borealis-stable.yml`, and every feature is its own small file under
`recipes/features/`. Static files live under `files/` and get copied verbatim
into the image by the features that need them; shell scripts referenced by
recipes sit in `files/scripts/`. The installer folder is the titanoboa live ISO
builder, and the GitHub workflows in `.github/workflows/` build the images,
the ISOs, and publish the releases.

## How the first-boot Flatpaks work

This is the managed list approach Bluefin uses. The file `files/flatpaks/etc/flatpak/install`
lists app ids, one per line, with `#` comments allowed. A small systemd service
runs once at first boot, adds Flathub if it is missing, installs the list, and
writes a stamp under /var so it never repeats. The stamp lives in /var, which
means a rebase wipes it and the defaults come back on the next image. Nothing
is baked into the image, so the apps update normally on the running system.
If the network is down the service just retries quietly in the background. The
whole thing is intentionally boring, and editing the list is all that is needed
to change what new systems get.

## Maintaining this repo

The rules I try to follow, so this stays a hobby project and not a job. You
should use them too if you fork it.

One feature is one file in `recipes/features/`, and adding a feature to the
image is adding a single `- from-file` line to both recipes. Static files
shipped by a feature live next to it under `files/`. Shell scripts referenced
by recipes go in `files/scripts/` and are named there. Nothing in a build may
need the network unless there really is no alternative (Steam is currently the
only exception), because downloads are the classic way a build breaks. Never
write to /var, /home or the bootloader from a build script; first boot concerns
belong in a systemd unit or an autostart entry, like the wallpaper and the
Flatpak installer do. Every script starts with `set -euo pipefail`. The
titanoboa action in the ISO workflow is pinned on purpose, and should only be
bumped together with a tested ISO build. If something user visible changes,
update this README.

## License

MIT. Use it, change it, ask me if you want something in it.