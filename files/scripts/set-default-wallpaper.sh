#!/usr/bin/bash
set -euo pipefail

# Sets the default Plasma wallpaper (the one seen on the live ISO and on each
# new user's first login) to a wallpaper already installed by the wallpapers
# feature. The filename to look up (under /usr/share/backgrounds) comes from
# the UBLUE_WALLPAPER env var set in the recipe.
#
# KDE/Plasma has no system-wide "default wallpaper" key like GNOME's gschema:
# each user's wallpaper lives in their own plasma config, generated at first
# login. So a one-shot per-user autostart entry applies the wallpaper exactly
# once (on the live session and on each user's first login), then never again,
# so users can change it afterwards without it being reset.

wallpaper="${UBLUE_WALLPAPER:?UBLUE_WALLPAPER env var is required}"
wall="$(find /usr/share/backgrounds -type f -iname "${wallpaper}" -print -quit 2>/dev/null || true)"
if [[ -z "${wall}" ]]; then
    echo "error: wallpaper '${wallpaper}' not found under /usr/share/backgrounds" >&2
    exit 1
fi

mkdir -p /usr/libexec/ublue
cat > /usr/libexec/ublue/set-plasma-wallpaper.sh <<EOF
#!/usr/bin/bash
set -euo pipefail
marker="\$HOME/.config/borealfloat-wallpaper.done"
[ -e "\$marker" ] && exit 0
command -v plasma-apply-wallpaperimage >/dev/null 2>&1 || exit 0
plasma-apply-wallpaperimage "$wall" >/dev/null 2>&1 || true
: > "\$marker"
EOF
chmod +x /usr/libexec/ublue/set-plasma-wallpaper.sh

mkdir -p /etc/xdg/autostart
cat > /etc/xdg/autostart/borealfloat-wallpaper.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=Borealfloat default wallpaper
Exec=/usr/libexec/ublue/set-plasma-wallpaper.sh
X-KDE-autostart-phase=2
OnlyShowIn=KDE;
EOF

echo "Default wallpaper ${wall} scheduled for the first Plasma session"