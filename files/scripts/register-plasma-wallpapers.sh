#!/usr/bin/bash
set -euo pipefail

# Registers a directory of loose wallpaper images with the Plasma (KDE) image
# wallpaper picker (Settings -> Wallpaper -> Wallpaper type: Image) by building
# a Plasma wallpaper package per image under /usr/share/wallpapers/<Collection>/.
#
# KDE only lists wallpapers that are packaged in /usr/share/wallpapers/<Id>/ with
# a metadata.json (like kde-wallpapers / plasma-workspace-wallpapers do); bare
# files dumped into /usr/share/backgrounds are ignored by the picker. The
# collections Borealis ships flat (Auveiss-Modified, Nature) therefore need one
# package per image.
#
# Usage:
#   register-plasma-wallpapers.sh <wallpaper-dir> <collection-id>
#
#   wallpaper-dir  directory to scan for images (flat, non-recursive)
#   collection-id  short id used as the package prefix, e.g. "auveiss-modified"

src="${1:?usage: $0 <wallpaper-dir> <collection-id>}"
collection="${2:?usage: $0 <wallpaper-dir> <collection-id>}"

if [[ ! -d "$src" ]]; then
    echo "error: wallpaper directory does not exist: $src" >&2
    exit 1
fi

count=0
while IFS= read -r -d '' image; do
    base="$(basename "$image")"
    name="${base%.*}"
    slug="$(printf '%s' "$name" | tr '[:upper:] ' '[:lower:]-' | tr -c 'a-z0-9-' '-')"

    dest="/usr/share/wallpapers/${collection}/${slug}"
    mkdir -p "$dest"
    cp -n "$image" "$dest/$base"

    {
        printf '{\n'
        printf '  "KPlugin": {\n'
        printf '    "Id": "%s.%s",\n' "$collection" "$slug"
        printf '    "Name": "%s: %s",\n' "$collection" "$name"
        printf '    "Description": "%s wallpaper collection",\n' "$collection"
        printf '    "Authors": [ { "Name": "Float" } ],\n'
        printf '    "Version": "1.0",\n'
        printf '    "License": "GPL"\n'
        printf '  },\n'
        printf '  "Image": "%s"\n' "$base"
        printf '}\n'
    } > "$dest/metadata.json"

    count=$((count + 1))
done < <(
    find "$src" -maxdepth 1 -type f \( \
        -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) -print0 | sort -z
)

echo "Registered $count Plasma wallpapers from $src"
if (( count == 0 )); then
    exit 1
fi