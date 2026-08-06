#!/usr/bin/env bash

# set -e

ALLOWED_LLAMA_COMMANDS=("llama-mtmd-cli" "llama-cli")

usage() {
  echo "Usage: $0 <llama-cpp-command> <directory> [-D|--dry-run] [-P|--prompt-append <string>] [-- <extra_args>...]"
  echo "  allowed <llama-cpp-command> values: ${ALLOWED_LLAMA_COMMANDS[@]}"
  exit 1
}

if [ -z "$1" ]; then
  usage
fi

contains_element() {
    local match="$1"
    shift
    for element in "$@"; do
        [[ "$element" == "$match" ]] && return 0
    done
    return 1
}

LLAMA_COMMAND="$1" # should be `llama-mtmd-cli` or `llama-cli`

contains_element "$LLAMA_COMMAND" "${ALLOWED_LLAMA_COMMANDS[@]}" || {
  echo "\"$LLAMA_COMMAND\" is not a valid llama-cpp-command."
  usage
}

DIR="$2"

# get basename of target directory
BASENAME=$(basename "$DIR")

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
        -P|--prompt-append)
            if [ -z "$2" ]; then
                echo "Error: $1 requires a non-empty argument"
                usage
            fi
            ADDITIONAL_INSTRUCTIONS+=" $2"
            shift 2
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


join_by() {
  local separator="$1"
  shift
  local first=1
  for item in "$@"; do
    if [ $first -eq 1 ]; then
      printf '%s' "$item"
      first=0
    else
      printf '%s%s' "$separator" "$item"
    fi
  done
}

PROMPT_ATTACHMENTS=()
# using -n (opposite of -z) here because $IMAGES and $AUDIO are really strings.
[[ -n "$IMAGES" ]] && PROMPT_ATTACHMENTS+=("a series of still images")
[[ -n "$AUDIO" ]] && PROMPT_ATTACHMENTS+=("the audio track")

read -r -d '' DEFAULT_PROMPT << EOF
Attached is $(echo $(join_by " and " "${PROMPT_ATTACHMENTS[@]}"))
from a single video. The filename of the video is \"$BASENAME\".

Format all output as Markdown.

$ADDITIONAL_INSTRUCTIONS

Use the following template for your response:

# < filename of video >

## Summary

< Summary of the video >

## Text

< Any recognizable text seen in any video frames >

## Language

< If audio is present and recognized as speech, try to guess the language >

## Transcription

< Transcription of audio, if applicable. Include speaker names (or consistent description, if name not known) >

## Tags

< a bulleted list of \"tags\" which are applicable to this video, as would be used on a video-sharing service >

EOF

# Build argument list
ARGS=()
ARGS+="-p \"$DEFAULT_PROMPT\""

if [[ "$LLAMA_COMMAND" == "llama-cli" ]]; then
  ARGS+=("--single-turn" "--reasoning off")
fi

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

# Run $(LLAMA_COMMAND)
QUOTED_ARGS=()
  for arg in "${EXTRA_ARGS[@]}"; do
    if [[ "$arg" == -* ]]; then
      QUOTED_ARGS+=("$arg")
    else
      QUOTED_ARGS+=("\"$arg\"")
    fi
  done

CMD="$LLAMA_COMMAND --image \"$IMAGE_LIST\" --audio \"$AUDIO_LIST\" ${ARGS[@]} ${QUOTED_ARGS[@]}"

echo "Command:"
echo "$CMD"

if [[ "$DRY_RUN" == "false" ]]; then
  eval "$CMD"
fi
