#!/bin/bash

# Script to extract audio from a video at regular intervals using ffmpeg

# Usage: ./extract_audio.sh <video_filename> [-o/--output <directory>] [-y/--yes]

# Check for required argument: video filename
if [ $# -lt 1 ]; then
    echo "Usage: $0 <video_filename> [-o/--output <directory>] [-y/--yes]"
    exit 1
fi

# Parse command line arguments
VIDEO_FILE="$1"
OUTPUT_DIR="${VIDEO_FILE%.*}"  # Default output directory is video filename without extension
AUTO_DELETE="false"  # Default: do not auto-delete

# Parse optional arguments
shift  # Remove the first argument (video file)
while [[ $# -gt 0 ]]; do
    case "$1" in
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

# Define output file path
OUTPUT_FILE="$OUTPUT_DIR/audio.wav"

# Check for existing WAV file in output directory
existing_file=$(find "$OUTPUT_DIR" -maxdepth 1 -type f -name "audio.wav")

# If -y/--yes flag is provided, automatically delete existing file
if [ "$AUTO_DELETE" = "true" ] && [ -n "$existing_file" ]; then
    echo "Auto-delete enabled: Deleting existing audio file from $OUTPUT_DIR..."
    rm -v "$existing_file"
fi

# Only prompt if file exists and auto-delete is not enabled
if [ -n "$existing_file" ] && [ "$AUTO_DELETE" != "true" ]; then
    echo "Warning: Existing audio file found in $OUTPUT_DIR"
    echo "Choose action:"
    echo "1) Delete existing file and proceed with extraction"
    echo "2) Keep existing file and skip extraction" 
    echo "3) Cancel operation"
    
    read -p "Enter your choice [1-3]: " user_choice
    
    case $user_choice in
        1)
            echo "Deleting existing audio file..."
            rm -v "$existing_file"
            echo "Proceeding with audio extraction..."
            # Continue to ffmpeg command
            ;;
        2)
            echo "Keeping existing file. Extraction skipped."
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

# Extract audio using ffmpeg
# -acodec pcm_s16le: PCM WAV format
# -ar 16000: 16kHz sample rate
# -ac 1: mono audio
# -vn: ignore video stream

ffmpeg -i "$VIDEO_FILE" -acodec pcm_s16le -ar 16000 -ac 1 -vn "$OUTPUT_FILE"

# Check if ffmpeg command succeeded
if [ $? -eq 0 ]; then
    echo "Audio extracted successfully to $OUTPUT_FILE"
else
    echo "Error: Failed to extract audio"
    exit 1
fi