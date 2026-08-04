#!/bin/bash

# Script to extract frames from a video at regular intervals using ffmpeg

# Usage: ./extract_frames.sh <video_filename> [-i/--interval <seconds>] [-o/--output <directory>] [-y/--yes]

# Check for required argument: video filename
if [ $# -lt 1 ]; then
    echo "Usage: $0 <video_filename> [-i/--interval <seconds>] [-o/--output <directory>] [-y/--yes]"
    exit 1
fi

# Parse command line arguments
VIDEO_FILE="$1"
INTERVAL=30  # Default interval is 30 seconds
OUTPUT_DIR="${VIDEO_FILE%.*}"  # Default output directory is video filename without extension
AUTO_DELETE="false"  # Default: do not auto-delete

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
        -y|--yes)
            AUTO_DELETE="true"
            shift
            ;;
        *)
            echo "Error: Unknown argument '$1'"
            exit 1
            ;;
    esac
done

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Check for existing JPG files in output directory
existing_files=$(find "$OUTPUT_DIR" -maxdepth 1 -type f -name "*.jpg" | wc -l)

# If -y/--yes flag is provided, automatically delete existing files
if [ "$AUTO_DELETE" = "true" ] && [ "$existing_files" -gt 0 ]; then
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
            echo "Deleting existing JPG files..."
            find "$OUTPUT_DIR" -maxdepth 1 -type f -name "*.jpg" -exec rm -v {} \;
            echo "Proceeding with frame extraction..."
            # Continue to ffmpeg command
            ;;
        2)
            echo "Keeping existing files. Extraction skipped."
            exit 0
            ;;
        3)
            echo "Operation cancelled by user."
            exit 0
            ;;
        *)
            echo "Invalid choice. Operation cancelled."
            exit 1
            ;;
    esac
fi

# Extract frames using ffmpeg
# -vf "fps=1/$INTERVAL": extract 1 frame every INTERVAL seconds
# -vf "scale='min(iw,ih*2)':480": scale to max height of 480px, adjust width proportionally
# -q:v 2: set quality (2 is high quality)
# -f image2: output format (image sequence)
# output_%03d.png: output filename pattern

ffmpeg -i "$VIDEO_FILE" -vf "fps=1/$INTERVAL, scale=-1:480" -q:v 2 -f image2 "$OUTPUT_DIR/output_%03d.jpg"

# Check if ffmpeg command succeeded
if [ $? -eq 0 ]; then
    echo "Frames extracted successfully to $OUTPUT_DIR"
else
    echo "Error: Failed to extract frames"
    exit 1
fi