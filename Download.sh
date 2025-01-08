#!/bin/bash

# Directory to save the files
OUTPUT_DIR="data/raw_fastq"

# Input file containing the URLs
INPUT_FILE="configs/links.txt"

# Check if curl is installed
if ! command -v curl &> /dev/null; then
    echo "curl is not installed. Attempting to install it..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y curl
    elif command -v yum &> /dev/null; then
        sudo yum install -y curl
    elif command -v brew &> /dev/null; then
        brew install curl
    else
        echo "Package manager not found. Please install curl manually."
        exit 1
    fi
else
    echo "curl is already installed. Proceeding with the script..."
fi

# Create the output directory if it doesn't exist
if [[ ! -d "$OUTPUT_DIR" ]]; then
    mkdir -p "$OUTPUT_DIR"
fi

# Check if the input file exists
if [[ ! -f "$INPUT_FILE" ]]; then
    echo "Input file $INPUT_FILE does not exist."
    exit 1
fi

# Read each line in the input file and download the file
while IFS= read -r url; do
    if [[ -n "$url" ]]; then
        echo "Downloading $url..."
        curl -o "$OUTPUT_DIR/$(basename "$url")" "$url"
    fi
done < "$INPUT_FILE"

echo "Download complete. Files saved in $OUTPUT_DIR"