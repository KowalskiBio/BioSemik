#!/bin/bash

# Define the path to the env.yaml file
env_file="./configs/env.yaml"

# Check if the env.yaml file exists
if [[ ! -f "$env_file" ]]; then
    echo "Error: Environment file $env_file does not exist. Please reinstall the program."
    exit 1
fi

# Get the environment name from env.yaml
env_name=$(grep "name:" "$env_file" | awk '{print $2}')

# Check if the environment already exists
if conda env list | grep -q "^$env_name"; then
    while true; do
        read -p "Conda environment '$env_name' already exists. Do you want to (s)kip or (u)pdate it? [s/u]: " choice
        if [[ "$choice" == "s" || "$choice" == "S" ]]; then
            echo "Skipping environment creation..."
            break
        elif [[ "$choice" == "u" || "$choice" == "U" ]]; then
            echo "Updating Conda environment '$env_name'..."
            conda env update --file "$env_file" --prune
            if [[ $? -ne 0 ]]; then
                echo "Error: Failed to update Conda environment from $env_file."
                exit 1
            fi
            echo "Conda environment '$env_name' updated successfully."
            break
        else
            echo "Invalid choice. Please enter 's' to skip or 'u' to update."
        fi
    done
else
    echo "Creating new Conda environment: $env_name..."
    conda env create -f "$env_file"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to create Conda environment from $env_file."
        exit 1
    fi
    echo "Conda environment '$env_name' created successfully."
fi

echo "Conda environment '$env_name' is ready."

# Ensure Conda is initialized by sourcing conda.sh
echo "Ensuring Conda is activated..."
source $(conda info --base)/etc/profile.d/conda.sh

# Initialize Conda if it hasn't been done already
echo "Initializing Conda..."
conda init

# Activate the Conda environment
echo "Activating the Conda environment..."
conda activate "$env_name"