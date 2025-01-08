#!/bin/bash

# Clear previous log (optional)
: > script.log

# Redirect output to both terminal and log file
exec > >(tee -a script.log) 2>&1

echo "Script started at: $(date)"

# Exit immediately if a command exits with a non-zero status
set -e

# Define the script directory
script_dir="./scripts"

# Function to get validated yes/no input
get_yes_no() {
    local prompt="$1"
    local response=""
    while true; do
        read -p "$prompt (yes/no): " response
        response=$(echo "$response" | tr '[:upper:]' '[:lower:]') # Convert to lowercase
        if [[ "$response" == "yes" || "$response" == "no" ]]; then
            echo "$response" # Return the valid response
            break
        else
            echo "Invalid input. Please enter 'yes' or 'no'." >&2
        fi
    done
}

# Main logic in a loop
while true; do
    # Get validated yes/no inputs
    check_quality=$(get_yes_no "Do you want to check the quality of your data?")
    trim_data=$(get_yes_no "Do you want to trim your data?")
    if [[ "$trim_data" == "no" ]]; then
        echo "You have opted not to trim your data."
        echo "Please ensure your data is of good quality or already trimmed before proceeding."
        echo "For further analysis, make sure that the data is located in the ./data/trimmed_fastq directory."
    fi

    # Validate database selection
    database=""
    while true; do
        read -p "For annotation, do you want to use (e)nsembl or (r)efseq? (e/r): " database
        database=$(echo "$database" | tr '[:upper:]' '[:lower:]')
        if [[ "$database" == "e" || "$database" == "r" ]]; then
            # Valid input, break the loop
            break
        else
            echo "Invalid input. Please enter 'e' for ensembl or 'r' for refseq."
        fi
    done

    # Map database choice to a readable format
    if [[ "$database" == "e" ]]; then
        database="Ensembl"
    elif [[ "$database" == "r" ]]; then
        database="RefSeq"
    fi

    # Analyze data question
    analyze_data=$(get_yes_no "After Salmon is done, do you want to analyze your data?")
    if [[ "$analyze_data" == "yes" && "$database" == "Ensembl" ]]; then
        echo "Please enter the transcript ID(s) of interest in ENST format (e.g., ENST00000337653.7)."
        read -p "If multiple IDs are to be searched for, separate them with space: " ide
    elif [[ "$analyze_data" == "yes" && "$database" == "RefSeq" ]]; then
        echo "Please enter the transcript ID(s) of interest in NM format (e.g., NM_020984.4)."
        read -p "If multiple IDs are to be searched for, separate them with space: " idr
    fi

    # Echo the user's selections
    echo
    echo "You have selected the following options:"
    echo "  - Check quality of data: $check_quality"
    echo "  - Trim data: $trim_data"
    echo "  - Database for annotation: $database"
    if [[ "$analyze_data" == "yes" ]]; then
        echo "  - Analyze data: $analyze_data"
        if [[ "$database" == "Ensembl" ]]; then
            echo "  - Transcript IDs: $ide"
        elif [[ "$database" == "RefSeq" ]]; then
            echo "  - Transcript IDs: $idr"
        fi
    else
        echo "  - Analyze data: $analyze_data"
    fi

    # Ask for confirmation to continue
    continue_choice=$(get_yes_no "Do you wish to continue with these settings?")
    if [[ "$continue_choice" == "yes" ]]; then
        break # Exit the loop and proceed with the script
    else
        echo "Restarting the setup process..."
        echo
    fi
done

# Export the variables to make them available to the scripts
export CHECK_QUALITY="$check_quality"
export TRIM_DATA="$trim_data"
export DATABASE="$database"
export ANALYSIS="$analyze_data"
export IDE="$ide"
export IDR="$idr"

echo "Configuration complete. Proceeding with the script..."
# Add the rest of your script logic here

# Running arbitrary scripts
echo "Installing Conda..."
"$script_dir/Conda_install.sh"
echo "Conda successfully detected. Proceeding to the next step."

echo "Creating Conda environment. This will take some time."
"$script_dir/Conda_env.sh"
echo "Conda environment detected. Proceeding to the next step."

# Run the first QC based on the answer
if [[ "$check_quality" == "yes" ]]; then
    echo "Checking the quality of your data with FASTQC..."
    "$script_dir/FASTQC.sh"
    echo "FASTQC completed successfully. Proceeding to the next step..."
    
    echo "Wrapping the FASTQC results with MULTIQC..."
    "$script_dir/MULTIQC.sh"
    echo "MULTIQC completed successfully. Results found in ./output/multiqc_raw. 
    Proceeding to the next step."
fi

# Run the trimming based on the answer
if [[ "$trim_data" == "yes" ]]; then
    echo "Trimming your data with Trim Galore!..."
    "$script_dir/Trimming.sh"
    echo "Trimming completed successfully. Proceeding to the next step."
fi

# Run second QC based on the answers to both questions
if [[ "$check_quality" == "yes" && "$trim_data" == "yes" ]]; then
    echo "Checking the quality of trimmed data with FASTQC..."
    "$script_dir/FASTQC2.sh"
    echo "Analysis completed successfully. Proceeding to MULTIQC..."
    
    echo "Wrapping the trimmed FASTQC results with MULTIQC..."
    "$script_dir/MULTIQC2.sh"
    echo "MULTIQC completed successfully. Results found in /output/multiqc_trimmed.
     Proceeding to the next step."
else
    echo "Skipping second QC as either quality check or trimming was not selected."
fi

# Run Salmon
echo "Running Salmon..."
"$script_dir/Salmon.sh"
echo "Salmon quantification completed successfully."


if [[ "$analyze_data" == "yes" ]]; then
    echo "Creating combined table from your Salmon results..."
    "$script_dir/Compiling.sh"
    echo "Analysis completed successfully. Proceeding to the next step."

    echo "Preparing the search for your transcripts..."
    "$script_dir/Analysis.sh"
    echo "Final analysis completed successfully."
else
    echo "Skipping analysis as it was not selected."
fi

echo "All scripts completed successfully! Thank you for using the RaptorQuant pipeline."