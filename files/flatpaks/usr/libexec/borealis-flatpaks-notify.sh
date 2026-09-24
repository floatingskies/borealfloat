#!/usr/bin/bash
# Runs as the user at each login (via /etc/xdg/autostart). If the first-boot
# Flatpak install has completed, tells the user their default apps are ready —
# once per user (marker under ~/.config), so it never nags on later logins.
# If the install is still running, this exits silently and a later login
# notifies. Autostart is asynchronous, so nothing ever blocks the session.
set -euo pipefail

marker="${HOME}/.config/borealis-flatpaks-notified"
[[ -e "${marker}" ]] && exit 0
[[ -e /var/lib/borealis/flatpaks.done ]] || exit 0

# Let the session bus settle before calling notify-send.
sleep 3
if command -v notify-send >/dev/null 2>&1; then
    notify-send -a Borealis "Borealis apps installed" \
        "Your default apps (Flatseal, VLC) finished installing — they are in your app menu." || true
fi
: > "${marker}"