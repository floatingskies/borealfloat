#!/usr/bin/env bash

# This is a convenience script that takes care of starting the build process.
# Provided by BlueBuild templates (used by Universal Blue's forkable images).

set -euo pipefail

if [ $# -eq 0 ]; then
	echo "Usage: $0 <recipe>"
	echo "Example: $0 borealis-stable.yml"
	exit 1
fi

base_file=$(basename "$1")

if [[ "$base_file" == *.yml ]]; then
	# We have a recipe file
	recipe_file="$1"
else
	# Otherwise it's an image name
	recipe_file="recipes/$1.yml"
fi

if [ ! -f "$recipe_file" ]; then
	echo "Recipe file not found: $recipe_file"
	exit 1
fi

bluebuild build "$recipe_file"