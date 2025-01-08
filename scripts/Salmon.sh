#!/bin/bash

# Check if the DATABASE variable is set
if [[ -z "$DATABASE" ]]; then
    echo "Error: The database variable is not set. Please set it to 'Ensembl' or 'RefSeq' in Run.sh."
    exit 1
fi

# Set INDEX_DIR based on the DATABASE variable
if [[ "$DATABASE" == "Ensembl" ]]; then
    INDEX_DIR="./data/salmon/index/index_salmon_Ens_k23"
    echo "Salmon is using Ensembl as the annotation of choice."
elif [[ "$DATABASE" == "RefSeq" ]]; then
    INDEX_DIR="./data/salmon/index/index_salmon_NCBI_k23"
    echo "Salmon is using RefSeq as the annotation of choice."
else
    echo "Error: Invalid DATABASE value '$DATABASE'. Please set it to 'e' for ensembl or 'r' for refseq."
    exit 1
fi

# Set other paths
FASTQ_DIR="./data/trimmed_fastq"
LIBTYPE="A"

# Check if the FASTQ directory exists
if [ ! -d "$FASTQ_DIR" ]; then
    echo "Error: FASTQ directory $FASTQ_DIR does not exist."
    exit 1
fi

# Check if the index directory exists
if [ ! -d "$INDEX_DIR" ]; then
    echo "Error: Index directory $INDEX_DIR does not exist."
    exit 1
fi

# Iterate over all unique sample prefixes for R1 files (accepting multiple naming conventions)
for R1_FILE in "$FASTQ_DIR"/*{_1.fastq.gz,_1.fq.gz,_R1_*.fastq.gz,_R1_*.fq.gz}; do
    # Skip if no matches
    [ -e "$R1_FILE" ] || continue

    # Derive R2 file name based on R1 file name
    R2_FILE="${R1_FILE/_1_val_1.fq.gz/_2_val_2.fq.gz}"
    R2_FILE="${R2_FILE/R1_001_val_1.fq.gz/R2_001_val_2.fq.gz}"
    R2_FILE="${R2_FILE/_1_val_1.fastq.gz/_2_val_2.fastq.gz}"
    R2_FILE="${R2_FILE/R1_001_val_1.fastq.gz/R2_001_val_2.fastq.gz}"
    
    # Check if the R2 file exists
    if [ ! -f "$R2_FILE" ]; then
        echo "Warning: R2 file $R2_FILE not found for R1 file $R1_FILE. Skipping..."
        continue
    fi

    # Extract the sample name
    SAMPLE_NAME=$(basename "$R1_FILE" | sed -E 's/_val_[12].*//')

    # Create output directory
    OUTPUT_DIR="./output/salmon_results/${SAMPLE_NAME}"
    mkdir -p "$OUTPUT_DIR"

    # Activate the Conda environment
    echo "Activating the power of Salmon..."
    source "$(conda info --base)/etc/profile.d/conda.sh"
    conda activate raptor_quant

    # Run Salmon quantification
    echo "Running Salmon for $SAMPLE_NAME..."
    salmon quant -i "$INDEX_DIR" -l "$LIBTYPE" \
        -1 "$R1_FILE" -2 "$R2_FILE" \
        --validateMappings -o "$OUTPUT_DIR"

    # Check if Salmon ran successfully
    if [ $? -eq 0 ]; then
        echo "Salmon quantification completed for $SAMPLE_NAME"
    else
        echo "Error: Salmon failed for $SAMPLE_NAME"
    fi
done