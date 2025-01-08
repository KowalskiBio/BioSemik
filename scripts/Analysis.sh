#!/bin/bash

# Define input and output files
combined_results_file="./output/salmon_results/combined_results.tsv"
filtered_output_file="./output/salmon_results/filtered_results.tsv"

# Check if IDE or IDR variables are set
if [[ -z "$IDE" && -z "$IDR" ]]; then
    echo "Error: No valid IDs provided for Ensembl or RefSeq. Exiting..."
    exit 1
fi

# Initialize arrays for ENST and NM IDs
user_ENSTs=()
user_NMs=()

# Process IDE (ENST IDs)
if [[ -n "$IDE" ]]; then
    for id in $IDE; do
        if [[ "$id" == ENST* ]]; then
            user_ENSTs+=("$id")
        else
            echo "Warning: '$id' in IDE is not a valid ENST ID and will be ignored."
        fi
    done
fi

# Process IDR (NM IDs)
if [[ -n "$IDR" ]]; then
    for id in $IDR; do
        if [[ "$id" == NM* ]]; then
            user_NMs+=("$id")
        else
            echo "Warning: '$id' in IDR is not a valid NM ID and will be ignored."
        fi
    done
fi

# Check if any valid IDs were provided
if [[ ${#user_ENSTs[@]} -eq 0 && ${#user_NMs[@]} -eq 0 ]]; then
    echo "Error: No valid ENST or NM IDs provided. Exiting."
    exit 1
fi

# Combine user-specified IDs into a single pattern
pattern=$(IFS="|"; echo "${user_ENSTs[*]} ${user_NMs[*]}" | tr ' ' '|')

# Print the pattern for debugging purposes (optional)
echo "Using the pattern: $pattern"

# Use perl to filter the combined_results.tsv file based on the pattern
perl -ne "print if /\t($pattern)\t/" "$combined_results_file" > "$filtered_output_file"

# Output success message
echo "Filtered results have been written to $filtered_output_file"