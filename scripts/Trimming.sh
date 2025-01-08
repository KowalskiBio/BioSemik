#!/bin/bash

# Define input and output directories
input_dir="./data/raw_fastq"
output_dir="./data/trimmed_fastq"

# Ensure the output directory exists
mkdir -p "$output_dir"

# Ensure that Conda is activated
source $(conda info --base)/etc/profile.d/conda.sh
conda activate salmon

## Ensure that Trim Galore is installed
if ! command -v trim_galore &> /dev/null; then
    echo "Error: trim_galore is not installed. Please install trim_galore and try again."
    exit 1
fi

# Loop through all _1.fastq.gz, _1.fq.gz, _R1_*.fastq.gz, and _R1_*.fq.gz files
for A in "$input_dir"/*{_1.fastq.gz,_1.fq.gz,_R1_*.fastq.gz,_R1_*.fq.gz}; do
    # Check if the file exists to avoid errors
    if [ ! -f "$A" ]; then
        continue
    fi
    
    # Define the corresponding _R2_ file based on the pattern
    R2="${A/_1.fastq.gz/_2.fastq.gz}"
    R2="${R2/_1.fq.gz/_2.fq.gz}"
    R2="${R2/_R1_/_R2_}"

    name=$(basename "${A%_R1_*}")

    # Define paths for trimmed output files
    trimmed_A="$output_dir/${name}_R1_val_1.fq.gz"
    trimmed_R2="$output_dir/${name}_R2_val_2.fq.gz"
    
    # Check if the trimmed files already exist
    if [[ -f "$trimmed_A" && -f "$trimmed_R2" ]]; then
        echo "Trimmed files for $name already exist. Skipping..."
    else
        echo "Processing $name: $A and $R2"
        # Run Trim Galore with paired-end data
        trim_galore --paired "$A" "$R2" --cores 6 -o "$output_dir"
    fi
done