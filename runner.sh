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
for img in $IMAGES; do
    ARGS+=("--image" "$img" )
done

# Expand audio into array entries
for wav in $AUDIO; do
    ARGS+=("--audio" "$wav" )
done

# Run llama-mtmd-cli
echo llama-mtmd-cli "${ARGS[@]}"