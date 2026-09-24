#!/usr/bin/bash
set -eou pipefail

# Steam (from negativo17) must not autostart on first login. Aurora already
# strips its own autostart, but the negativo17 package installs a desktop
# launcher we don't want firing up on every boot.
rm -f /etc/xdg/autostart/steam.desktop