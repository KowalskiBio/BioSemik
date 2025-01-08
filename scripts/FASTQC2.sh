#!/bin/bash

# Define input and output directories
input_dir="./data/trimmed_fastq"
output_dir="./output/fastqc_trimmed"

## Create the output directory if it does not exist
mkdir -p "$output_dir"

# Ensure that Conda is activated
source $(conda info --base)/etc/profile.d/conda.sh
conda activate salmon

## Ensure that FASTQC is installed
if ! command -v fastqc &> /dev/null; then
    echo "Error: FASTQC is not installed. Please install FASTQC and try again."
    exit 1
fi

# Perform quality control with FASTQC
fastqc -t 6 -o "$output_dir" "$input_dir"/*.{fastq,fq}.gz