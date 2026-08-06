#!/bin/bash

# Script to extract frames from a video at regular intervals using ffmpeg

# Usage: ./extract_frames.sh <video_filename> [-i/--interval <seconds>] [-h/--height <pixels>] [-o/--output <directory>] [-s/--start <seconds>] [-v/--verbose] [-y/--yes]

# Check for required argument: video filename
if [ $# -lt 1 ]; then
    echo "Usage: $0 <video_filename> [-i/--interval <seconds>] [-h/--height <pixels>] [-o/--output <directory>] [-s/--start <seconds>] [-v/--verbose] [-y/--yes]"
    exit 1
fi

# Parse command line arguments
VIDEO_FILE="$1"
INTERVAL=30  # Default interval is 30 seconds
OUTPUT_DIR="${VIDEO_FILE%.*}"  # Default output directory is video filename without extension
AUTO_DELETE="false"  # Default: do not auto-delete
START=2  # Default start time is 2 seconds
VERBOSE="false"  # Default: do not be verbose
HEIGHT=304  # Default height is 304 pixels to correlate with 528×304 res

# Parse optional arguments
shift  # Remove the first argument (video file)
while [[ $# -gt 0 ]]; do
    case "$1" in
        -i|--interval)
            if [[ -n "$2" ]] && [[ "$2" =~ ^[0-9]+$ ]]; then
                INTERVAL="$2"
                shift 2
            else
                echo "Error: --interval requires a numeric value"
                exit 1
            fi
            ;;
        -o|--output)
            if [[ -n "$2" ]]; then
                OUTPUT_DIR="$2"
                shift 2
            else
                echo "Error: --output requires a directory path"
                exit 1
            fi
            ;;
        -s|--start)
            if [[ -n "$2" ]] && [[ "$2" =~ ^[0-9]+$ ]]; then
                START="$2"
                shift 2
            else
                echo "Error: --start requires a numeric value"
                exit 1
            fi
            ;;
        -y|--yes)
            AUTO_DELETE="true"
            shift
            ;;
        -h|--height)
            if [[ -n "$2" ]] && [[ "$2" =~ ^[0-9]+$ ]]; then
                HEIGHT="$2"
                shift 2
            else
                echo "Error: --height requires a numeric value"
                exit 1
            fi
            ;;
        -v|--verbose)
            VERBOSE="true"
            shift
            ;;
        *)
            echo "Error: Unknown argument '$1'"
            exit 1
            ;;
    esac
done

# Strip commas from OUTPUT_DIR
OUTPUT_DIR="${OUTPUT_DIR//,/}"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"
if [ "$VERBOSE" = "true" ]; then
    echo "Creating output directory: $OUTPUT_DIR" >&2
fi

# Check for existing JPG files in output directory
if [ "$VERBOSE" = "true" ]; then
    echo "Checking for existing JPG files in $OUTPUT_DIR..." >&2
fi
existing_files=$(find "$OUTPUT_DIR" -maxdepth 1 -type f -name "*.jpg" | wc -l)

# If -y/--yes flag is provided, automatically delete existing files
if [ "$AUTO_DELETE" = "true" ] && [ "$existing_files" -gt 0 ]; then
    if [ "$VERBOSE" = "true" ]; then
        echo "Auto-delete enabled: Found $existing_files existing JPG files in $OUTPUT_DIR. Deleting..." >&2
    fi
    echo "Auto-delete enabled: Deleting existing JPG files from $OUTPUT_DIR..."
    find "$OUTPUT_DIR" -maxdepth 1 -type f -name "*.jpg" -exec rm -v {} \;
fi

# Only prompt if files exist and auto-delete is not enabled
if [ "$existing_files" -gt 0 ] && [ "$AUTO_DELETE" != "true" ]; then
    echo "Warning: $existing_files existing JPG file(s) found in $OUTPUT_DIR"
    echo "Choose action:"
    echo "1) Delete existing files and proceed with extraction"
    echo "2) Keep existing files and skip extraction"
    echo "3) Cancel operation"

    read -p "Enter your choice [1-3]: " user_choice

    case $user_choice in
        1)
            if [ "$VERBOSE" = "true" ]; then
                echo "User chose to delete existing files. Proceeding with deletion..." >&2
            fi
            echo "Deleting existing JPG files..."
            find "$OUTPUT_DIR" -maxdepth 1 -type f -name "*.jpg" -exec rm -v {} \;
            echo "Proceeding with frame extraction..."
            # Continue to ffmpeg command
            ;;
        2)
            if [ "$VERBOSE" = "true" ]; then
                echo "User chose to keep existing files. Skipping extraction." >&2
            fi
            echo "Keeping existing files. Extraction skipped."
            exit 0
            ;;
        3)
            if [ "$VERBOSE" = "true" ]; then
                echo "User chose to cancel operation." >&2
            fi
            echo "Operation cancelled by user."
            exit 0
            ;;
        *)
            if [ "$VERBOSE" = "true" ]; then
                echo "User entered invalid choice '$user_choice'. Operation cancelled." >&2
            fi
            echo "Invalid choice. Operation cancelled."
            exit 1
            ;;
    esac
fi

# Extract frames using ffmpeg
# -vf "fps=1/$INTERVAL": extract 1 frame every INTERVAL seconds
# -vf "scale='-1:$HEIGHT": scale to max height of $HEIGHTpx, adjust width proportionally
# -q:v 2: set quality (2 is high quality)
# -f image2: output format (image sequence)
# output_%03d.png: output filename pattern

# `fps=1/$INTERVAL` starts at FPS/2, REGARDLESS of `-ss`! So we hack it here.
START_INDEX=$((-( $INTERVAL / 2 )+$START))

FFMPEG_COMMAND="ffmpeg -i \"$VIDEO_FILE\" -vf \"fps=1/$INTERVAL:start_time=$START_INDEX, scale=-1:$HEIGHT\" -q:v 2 -f image2 \"$OUTPUT_DIR/output_%03d.jpg\""
if [ "$VERBOSE" = "true" ]; then
    echo "Extracting frames with parameters:" >&2
    echo "  - Input file: $VIDEO_FILE" >&2
    echo "  - Start time: $START seconds" >&2
    echo "  - Interval: $INTERVAL seconds" >&2
    echo "  - Output directory: $OUTPUT_DIR" >&2
    echo "  - Output pattern: output_%03d.jpg" >&2
    echo "  - Height: $HEIGHT pixels" >&2
    echo "FFmpeg command:" >&2
    echo $FFMPEG_COMMAND >&2
fi

eval "$FFMPEG_COMMAND"

# Check if ffmpeg command succeeded
if [ $? -eq 0 ]; then
    if [ "$VERBOSE" = "true" ]; then
        echo "Frame extraction completed successfully." >&2
    fi
    echo "Frames extracted successfully to $OUTPUT_DIR"
else
    if [ "$VERBOSE" = "true" ]; then
        echo "Frame extraction failed with error code $?" >&2
    fi
    echo "Error: Failed to extract frames"
    exit 1
fi