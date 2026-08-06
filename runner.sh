#!/usr/bin/env bash

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <directory> [-D|--dry-run] [-- <extra_args>...]"
    exit 1
fi

DIR="$1"

# Shift to process remaining arguments
shift

DRY_RUN=false
EXTRA_ARGS=()

while [ "$#" -gt 0 ]; do
    case "$1" in
        -D|--dry-run)
            DRY_RUN=true
            shift
            ;;
        --)
            shift
            EXTRA_ARGS=("$@")
            break
            ;;
        *)
            EXTRA_ARGS+=("$1")
            shift
            ;;
    esac
done

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
QUOTED_ARGS=()
  for arg in "${EXTRA_ARGS[@]}"; do
    if [[ "$arg" == -* ]]; then
      QUOTED_ARGS+=("$arg")
    else
      QUOTED_ARGS+=("\"$arg\"")
    fi
  done

CMD="llama-mtmd-cli --image \"$IMAGE_LIST\" --audio \"$AUDIO_LIST\" ${QUOTED_ARGS[@]}"

if $DRY_RUN; then
  echo "$CMD"
else
  eval "$CMD"
fi
