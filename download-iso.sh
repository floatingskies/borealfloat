#!/bin/bash

# Usage:
#
#  ./download-iso.sh [IMAGE_NAME] [IMAGE_TAG]
#
#   IMAGE_NAME is borealfloat (default)
#   TAG_NAME is one of stable, latest (default is stable)
#

if [ -z $(command -v podman) ]; then
    echo "Podman is required"
    exit 1
fi
IMAGE_NAME=${1-borealfloat}
IMAGE_TAG=${2-stable}
echo "Creating an ISO for the $IMAGE_NAME:$IMAGE_TAG image"
rm -rf ./output
mkdir ./output
if ! sudo podman run --rm --privileged --volume ./output:/build-container-installer/output --pull=always \
 ghcr.io/jasonn3/build-container-installer:latest IMAGE_REPO=ghcr.io/floatingskies \
 IMAGE_NAME=$IMAGE_NAME \
 IMAGE_TAG=$IMAGE_TAG \
 VARIANT=Kinoite ; then
    echo "Failed to download image"
    exit 1
fi
sudo chown $USER:$USER output/*
BASENAME=$IMAGE_NAME-$(date +"%Y%m%d")
sudo mv output/deploy.iso output/$BASENAME.iso
sudo mv output/deploy.iso-CHECKSUM output/$BASENAME.iso-CHECKSUM