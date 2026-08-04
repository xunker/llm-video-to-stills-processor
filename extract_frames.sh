#!/bin/bash

# Script to extract frames from a video at regular intervals using ffmpeg

# Usage: ./extract_frames.sh <video_filename> [interval] [output_directory]

# Check for required argument: video filename
if [ $# -lt 1 ]; then
    echo "Usage: $0 <video_filename> [interval] [output_directory]"
    exit 1
fi

# Assign command line arguments
VIDEO_FILE="$1"
INTERVAL="${2:-30}"  # Default interval is 30 seconds
OUTPUT_DIR="${3:-${VIDEO_FILE%.*}}"  # Default output directory is video filename without extension

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Check for existing JPG files in output directory
existing_files=$(find "$OUTPUT_DIR" -maxdepth 1 -type f -name "*.jpg" | wc -l)

if [ "$existing_files" -gt 0 ]; then
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