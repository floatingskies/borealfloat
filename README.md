# borealfloat &nbsp; [![bluebuild build badge](https://github.com/floatingskies/borealfloat/actions/workflows/build-daily.yml/badge.svg)](https://github.com/floatingskies/borealfloat/actions/workflows/build-daily.yml)

A bit opinionated distro made by Float.

A set of [Bootable Container](https://containers.github.io/bootable/) images built on top of [Aurora DX](https://ublue-os.github.io/#aurora) (KDE Plasma 6) with [BlueBuild](https://blue-build.org)'s tools. Everything below is baked into the image at build time as a layer over the Universal Blue base.

Modifications baked into the image:

-   Firefox as the default browser (installed from RPM)
-   **Default wallpaper** — `fox.jpg` from the `floating-skies` collection (available alongside `floating-woof` and the System76, Framework, Ubuntu, and KDE/Plasma collections in the Plasma wallpaper picker)
-   [Intel One Mono](https://www.intel.com/content/www/us/en/company-overview/one-monospace-font.html) set as the default interface font, matching Floatfin on the GNOME side
-   Steam installed from negativo17 (Aurora does not ship it, unlike Bazzite)
-   The OS identifies itself as *Borealfloat* — Settings → About, installer branding, hostname
-   Aurora's *uwelcome* login banner is removed; instead the fish greeting (and `fastfetch`) shows a lean system summary with the foxy.png logo and a **Borealfloat** title
-   The default Plasma wallpaper is applied once (first login) and never overwritten again, so you can change it freely
-   A dev-ops / sysadmin / web-dev CLI toolkit baked in: `ansible-core`, `gh`, `git-lfs`, `jq`, `shellcheck`, `sshpass`, `bind-utils`, `htop`, `iotop`, `iperf3`, `mtr`, `ncdu`, `net-tools`, `sysstat`, `tmux`, `tree`, `whois`, `wget`, `btop`, `fd-find`, `fzf`, `pv`, `ripgrep`, `nodejs`, `npm`, and `python3-pip`

From Aurora DX, you keep the usual KDE tooling out of the box. Rootful Docker and Starship are disabled by default, and Tailscale doesn't autostart.

Aurora's default Flatpaks still install on first login; no extra Flatpaks are baked into the image.

## Image Tags

`borealfloat` is an overlay on [Aurora DX](https://ublue-os.github.io/#aurora) following Aurora's image channels:

-   `ghcr.io/floatingskies/borealfloat:stable` -- Aurora's stable stream, updated weekly
-   `ghcr.io/floatingskies/borealfloat:latest` -- Aurora's latest stream, updated daily

## Installation

First, install any [Fedora Atomic](https://fedoraproject.org/atomic-desktops/) or [Universal Blue](https://universal-blue.org) desktop edition (preferably one that features KDE Plasma, like Kinoite or Aurora).

Then use `bootc switch` to switch to the image. For example:

```
sudo bootc switch ghcr.io/floatingskies/borealfloat:latest --enforce-container-sigpolicy
```

Then reboot

```
systemctl reboot
```

## Installing via ISO

If you have `podman` installed on your system, you can generate an offline ISO with the `download-iso.sh` script in this directory, like this:

```
./download-iso.sh borealfloat stable
```

where `$IMAGE_NAME` is `borealfloat` and `$TAG_NAME` corresponds to `stable` or `latest` (the script defaults to `borealfloat:stable` if you omit both).

## Live ISO Images

Like [Aurora](https://ublue-os.github.io) and [Bazzite](https://bazzite.gg), live desktop ISOs are built using [Titanoboa](https://github.com/ublue-os/titanoboa). Trigger the **"Build Live ISOs"** GitHub Actions workflow ([Actions → Build Live ISOs](https://github.com/floatingskies/borealfloat/actions/workflows/build-iso.yml)) and download the artifact:

-   `borealfloat-stable-live-amd64.iso` — live Aurora DX desktop with the installed image inside

Boot the ISO and you get the full desktop running live from the image. To install the image to disk, launch **"Install to Disk"** from the desktop (Anaconda). The installer will also offer to enroll the Universal Blue secure boot key (password: `universalblue`) so it can boot with Secure Boot; it also works fine without Secure Boot, or you can enroll your own keys later.

## Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the signature by downloading the `cosign.pub` file from this repo and running the following command:

```
cosign verify --key cosign.pub ghcr.io/floatingskies/borealfloat:stable
cosign verify --key cosign.pub ghcr.io/floatingskies/borealfloat:latest
```

## Building Locally

```
./build-image.sh [recipe file]
```