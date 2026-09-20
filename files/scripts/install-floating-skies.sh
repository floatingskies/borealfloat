#!/usr/bin/bash

set -eou pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# The floating-skies collection is installed at /usr/share/backgrounds/floating-skies
# by the system files module. Register it with Plasma's wallpaper picker.
"$SCRIPT_DIR/register-plasma-wallpapers.sh" /usr/share/backgrounds/floating-skies floating-skies