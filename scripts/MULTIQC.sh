#!/bin/bash

# Define input and output directories
input_dir="./output/fastqc_raw"
output_dir="./output/multiqc_raw"

## Create the output directory if it does not exist
mkdir -p "$output_dir"

# Ensure that Conda is activated
source $(conda info --base)/etc/profile.d/conda.sh
conda activate raptor_quant

## Ensure that FASTQC is installed
if ! command -v multiqc &> /dev/null; then
    echo "Error: MULTIQC is not installed. Please install MULTIQC and try again."
    exit 1
fi

# Perform quality control with FASTQC
multiqc -o "$output_dir" "$input_dir"