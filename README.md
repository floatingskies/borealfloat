# Borealis &nbsp; [![bluebuild build badge](https://github.com/floatingskies/borealis/actions/workflows/build-daily.yml/badge.svg)](https://github.com/floatingskies/borealis/actions/workflows/build-daily.yml)

Borealis is an opinionated, polished Linux desktop image built on top of
[Aurora DX](https://ublue-os.github.io/#aurora) (KDE Plasma 6) with
[BlueBuild](https://blue-build.org)'s tools.

It aims to be the **perfect "tinkerer's" spin of Aurora DX**: everything you'd
want from a *DX* (developer experience) image with a full CLI toolkit, but with
a strong default focus on **stability**, **ease of use**, and **revitalizing
older hardware that is still perfectly good**.

> **Design pillars (in order)**
>
> 1. **Stability** — nothing in this repo may break a booted system. No build
>    step depends on a third-party URL at runtime; no script touches `/var` or
>    the bootloader; every script fails loudly instead of silently half-working.
> 2. **Ease of use** — defaults are set so a non-technical user (yes, including
>    your mother) can install and daily-drive it without touching a terminal.
> 3. **Universal Blue parity** — the build and ISO scripts are the same ones
>    Universal Blue ships for Aurora/Bazzite (see `build-image.sh` and the
>    `installer/` directory), so compatibility with the wider uBlue ecosystem
>    (ujust, Secure Boot keys, akmods, `bootc`) is guaranteed.
> 4. **Easy to maintain** — every feature is a small, documented, self-contained
>    file. A future maintainer (or a fork) can see exactly what each piece does.
>    See [Maintenance](#maintenance).

---

## What is baked in

- **Default wallpaper** — `snowy husklamute.jpg` (from the baked-in
  `Auveiss-Modified` collection). The default is applied exactly once on first
  login, so you can change it freely afterwards. The `Auveiss-Modified` and
  `Nature` collections are shipped **inside the image** (no build-time
  downloads) and appear in the Plasma wallpaper picker. Third-party vendor
  wallpaper packs (Ubuntu/Canonical, System76, Framework) are **not** included.
- **Firefox** as the default browser (RPM).
- **Intel One Mono** as the default interface font, matching Floatfin on GNOME.
- **Steam** from negativo17 (with autostart disabled).
- **Default Flatpaks installed at first boot** — the same managed-list mechanic
  Universal Blue uses (Bluefin-style): on first boot of the live ISO and of
  every installed system, a one-shot systemd service installs the apps listed
  in `/etc/flatpak/install` from Flathub (defaults: Flatseal and VLC). It runs
  in the background and never delays the desktop, even with no or slow internet
  (it retries in the background, and a first-login notification tells you when
  your apps are ready). Nothing is baked into the image, so the apps update
  normally on the live system. Edit the list in
  `files/flatpaks/etc/flatpak/install`.
- **A dev-ops / sysadmin / web-dev CLI toolkit**: `ansible-core`, `gh`,
  `git-lfs`, `jq`, `shellcheck`, `sshpass`, `bind-utils`, `htop`, `iotop`,
  `iperf3`, `mtr`, `ncdu`, `net-tools`, `sysstat`, `tmux`, `tree`, `whois`,
  `wget`, `btop`, `fd-find`, `fzf`, `pv`, `ripgrep`, `nodejs`, `npm`,
  `python3-pip`, and more.
- **KDE performance tuning** — KWin forced onto the OpenGL core profile
  (`kwinrc`) and animations sped up to 0.5× (`kdeglobals`), which keeps Plasma
  fast on older hardware *without* sacrificing the visuals (blur/shadows stay
  on). Every value is overridable in System Settings.
- **Borealis branding** everywhere: Settings → About, installer branding,
  hostname, fastfetch greeting (with a `borealis` logo), `os-release`.
- Aurora's `uwelcome` login banner is removed; the fish greeting shows a lean
  `fastfetch` summary instead.
- Rootful Docker and Starship are disabled by default; Tailscale does not
  autostart.

From Aurora DX you keep the usual KDE tooling, `ujust` recipes (the "I want to
do something powerful" menu — one command covers updates, rebasing, hardware
setups and more), and Aurora's default Flatpaks installed on first login.

## Image Tags

`borealis` is an overlay on [Aurora DX](https://ublue-os.github.io/#aurora)
following Aurora's image channels:

- `ghcr.io/floatingskies/borealis:stable` — Aurora's stable stream, rebuilt
  weekly (Tuesday)
- `ghcr.io/floatingskies/borealis:latest` — Aurora's latest stream, rebuilt
  daily

## Installation

First, install any [Fedora Atomic](https://fedoraproject.org/atomic-desktops/)
or [Universal Blue](https://universal-blue.org) desktop edition (preferably one
that features KDE Plasma, like Kinoite or Aurora).

Then use `bootc switch`:

```
sudo bootc switch ghcr.io/floatingskies/borealis:latest --enforce-container-sigpolicy
```

Then reboot:

```
systemctl reboot
```

That's it — the system updates itself in the background from then on.

### Installing via ISO (recommended for new users)

Head to the [Releases](https://github.com/floatingskies/borealis/releases)
page and download the latest `borealis-stable-live-amd64.iso`. Boot it with a
USB stick (or a VM) and choose **Install to Disk** — the Anaconda installer
will take care of everything and even offer to enroll the Universal Blue
Secure Boot key (password: `universalblue`).

> Live ISOs are built by the **"Build Live ISOs"** workflow
> ([Actions → Build Live ISOs](https://github.com/floatingskies/borealis/actions/workflows/build-iso.yml)),
> which uses the exact same `installer/` + titanoboa toolchain as Universal
> Blue's own images. Trigger it manually when you want a fresh ISO; it is
> published as the `iso-latest` GitHub Release.

### Offline ISO without waiting for CI

If you have `podman` on some other Linux system, you can generate an offline
install ISO locally:

```
./download-iso.sh borealis stable
```

## Building Locally

```
./build-image.sh borealis-stable.yml
```

or, passing just the name:

```
./build-image.sh borealis-stable
```

This is the same BlueBuild template script every Universal Blue fork uses. It
requires the `bluebuild` CLI (`curl --proto '=https' --tlsv1.2 -sSf https://sh.blue-build.org | sh`).

## Verification

Images are signed with [Sigstore](https://www.sigstore.dev/)'s
[cosign](https://github.com/sigstore/cosign). Verify a tag:

```
cosign verify --key cosign.pub ghcr.io/floatingskies/borealis:stable
cosign verify --key cosign.pub ghcr.io/floatingskies/borealis:latest
```

Live ISOs are cosign-signed and provenance-attested by the ISO workflow; the
`.sig` / `.json` files are attached to the `iso-latest` release.

## Repository layout

```
build-image.sh           # local image build (BlueBuild/UBlue template script)
download-iso.sh          # local offline-ISO helper
cosign.pub               # public key for image verification
recipes/
  borealis-latest.yml    # daily image (Aurora latest stream)
  borealis-stable.yml    # weekly image (Aurora stable stream)
  features/              # one small file per feature; recipes just include them
    system-files.yml     #   ships files/ + removes the uwelcome banner
    application-rpms.yml #   core RPM applications
    devops.yml           #   CLI toolkit
    kde.yml              #   KDE performance/polish (kwinrc)
    steam.yml            #   Steam + no autostart
    flatpaks.yml         #   default Flatpaks at first boot (managed list)
    fonts.yml            #   the font stack (Intel One Mono, Roboto, ...)
    wallpapers.yml       #   KDE + Borealis wallpaper collections
    aurora-overrides.yml #   disable docker/tailscale/starship
files/
  scripts/               # shell scripts referenced by recipe `type: script`
  system/                # copied verbatim into / by system-files.yml
  flatpaks/              # shipped by features/flatpaks.yml (app list + service)
  kde/                   # copied by the kde.yml feature
installer/               # titanoboa live-ISO builder (Universal Blue toolchain)
.github/workflows/
  build-daily.yml        # :latest image
  build-weekly.yml       # :stable image
  build-iso.yml          # live ISO + GitHub Release
```

## Maintenance

This repository is deliberately boring and small. Guidelines for future
maintainers (this applies to forks too):

- **One feature = one `recipes/features/*.yml` file.** Want to add a package?
  Create `recipes/features/my-thing.yml` with a `dnf` module and add a single
  `- from-file: features/my-thing.yml` line to both recipes.
- **Static files live in `files/system/` and are shipped by
  `system-files.yml`.** Add the file and you're done; it is copied as-is.
- **Shell scripts live in `files/scripts/`**, reference by filename in a
  `type: script` module (BlueBuild runs them from `files/scripts/`).
- **Never require network at image build time** unless there is no alternative
  (only `steam` uses the negativo17 repo today). Downloads in build scripts are
  the #1 source of broken builds — prefer baking files into the repo.
- **Never write to `/var`, `/home`, or the bootloader** from an image build
  script; those are first-boot concerns and must be handled by systemd units or
  first-login autostart (see how the default wallpaper is handled).
- **Every script** starts with `set -euo pipefail` and fails loudly with a
  clear `error:` message rather than continuing broken.
- Bump `titanoboa` (in `build-iso.yml`) deliberately and test an ISO before
  merging; the pin keeps rebuilds reproducible.
- When changing anything user-visible, update this README.

## License

[MIT](LICENSE)