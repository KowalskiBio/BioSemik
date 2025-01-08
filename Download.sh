#!/bin/bash

# Directory to save the files
OUTPUT_DIR="data/raw_fastq"

# Input file containing the URLs
INPUT_FILE="configs/links.txt"

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