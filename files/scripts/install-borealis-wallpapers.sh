#!/usr/bin/bash

set -eou pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Borealis ships its wallpaper collections baked into the image via the
# system-files module (files/system/usr/share/backgrounds/). Nothing is
# downloaded at build time, so the build cannot break because a vendor's
# download URL went away. Register each baked-in collection with Plasma's
# wallpaper picker (/usr/share/wallpapers/<Collection>/...metadata.json).
"$SCRIPT_DIR/register-plasma-wallpapers.sh" /usr/share/backgrounds/Borealis borealis
