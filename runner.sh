#!/usr/bin/env bash

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

DIR="$1"

if [ ! -d "$DIR" ]; then
    echo "Error: '$DIR' is not a directory"
    exit 1
fi

# Collect JPG images (alphabetically)
IMAGES=$(find "$DIR" -maxdepth 1 -type f -iname "*.jpg" | sort)

# Collect WAV files (alphabetically)
AUDIO=$(find "$DIR" -maxdepth 1 -type f -iname "*.wav" | sort)

# Build argument list
ARGS=()

# Expand images into array entries
IMAGE_LIST=""
  while IFS= read -r img; do
    if [ -z "$IMAGE_LIST" ]; then
      IMAGE_LIST="$img"
    else
      IMAGE_LIST="$IMAGE_LIST,$img"
    fi
  done <<< "$IMAGES"

# Expand audio into array entries
AUDIO_LIST=""
  while IFS= read -r wav; do
    if [ -z "$AUDIO_LIST" ]; then
      AUDIO_LIST="$wav"
    else
      AUDIO_LIST="$AUDIO_LIST,$wav"
    fi
  done <<< "$AUDIO"

# Run llama-mtmd-cli
echo llama-mtmd-cli "--image \"$IMAGE_LIST\" --audio \"$AUDIO_LIST\""