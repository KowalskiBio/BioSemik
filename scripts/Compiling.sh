#!/bin/bash

# Define the base directory where your SRR directories are located
base_dir="./output/salmon_results"

# Define the output file
output_file="${base_dir}/combined_results.tsv"

# Ensure the base directory exists
mkdir -p "$base_dir"

# Initialize the output file with headers
echo -e "SRR\tName\tTPM\tNumReads" > "$output_file"

# Iterate over each SRR directory in the base directory
for srr_dir in "${base_dir}"/*; do
    # Check if it's a directory
    if [ -d "$srr_dir" ]; then
        # Path to the quant.sf file
        sf_file="${srr_dir}/quant.sf"
        
        # Extract the directory name (SRR ID)
        srr_id=$(basename "$srr_dir")
        
        # Check if the quant.sf file exists
        if [ -f "$sf_file" ]; then
            # Extract the required columns and append to the output file
            awk -v srr="$srr_id" 'NR>1 {print srr, $1, $4, $5}' OFS='\t' "$sf_file" >> "$output_file"
        else
            echo "File $sf_file not found!"
        fi
    fi
done

echo "Results have been combined into $output_file"