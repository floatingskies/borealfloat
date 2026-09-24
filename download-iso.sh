#!/usr/bin/env bash
set -euo pipefail

# Convenience helper: generate an offline install ISO of the Borealis image
# using the community build-container-installer image (the same generic client
# many Universal Blue forks use).
#
# The "real" live desktop ISO is built in CI by the "Build Live ISOs" workflow
# (installer/ + titanoboa) and published to the GitHub Release page; this
# script is only for generating a quick offline installer without waiting on CI.
#
# Usage:
#   ./download-iso.sh [IMAGE_NAME] [IMAGE_TAG] [IMAGE_REPO]
#
#   IMAGE_NAME is borealis (default)
#   IMAGE_TAG  is one of stable, latest (default is stable)
#   IMAGE_REPO is the container registry + namespace (default ghcr.io/floatingskies)

if ! command -v podman >/dev/null 2>&1; then
    echo "error: podman is required" >&2
    exit 1
fi

IMAGE_NAME="${1:-borealis}"
IMAGE_TAG="${2:-stable}"
IMAGE_REPO="${3:-ghcr.io/floatingskies}"

echo "Creating an offline install ISO for ${IMAGE_REPO}/${IMAGE_NAME}:${IMAGE_TAG}"
rm -rf ./output
mkdir ./output

if ! sudo podman run --rm --privileged --volume ./output:/build-container-installer/output --pull=always \
    ghcr.io/jasonn3/build-container-installer:latest \
    IMAGE_REPO="$IMAGE_REPO" \
    IMAGE_NAME="$IMAGE_NAME" \
    IMAGE_TAG="$IMAGE_TAG" \
    VARIANT=Kinoite; then
    echo "error: failed to generate ISO" >&2
    exit 1
fi

sudo chown "$USER:$USER" output/*

BASENAME="${IMAGE_NAME}-${IMAGE_TAG}-offline-$(date +"%Y%m%d")"
sudo mv output/deploy.iso "output/${BASENAME}.iso"
sudo mv output/deploy.iso-CHECKSUM "output/${BASENAME}.iso-CHECKSUM"

echo "Done: output/${BASENAME}.iso"
echo "Verify: cat output/${BASENAME}.iso-CHECKSUM"