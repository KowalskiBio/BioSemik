#!/bin/bash

# Function to print messages
echo_message() {
    echo -e "\n>>> $1\n"
}

# Check if curl is installed
if ! command -v curl &> /dev/null; then
    echo "Error: curl is not installed. Please install curl and try again."
    exit 1
fi

# Define variables
MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh"
INSTALLER_NAME="Miniconda3-latest-MacOSX-x86_64.sh"
INSTALL_DIR="$HOME/.miniconda3"

# Download Miniconda installer
echo_message "Downloading Miniconda installer..."
curl -O "$MINICONDA_URL"
if [[ ! -f "$INSTALLER_NAME" ]]; then
    echo "Error: Failed to download Miniconda installer."
    exit 1
fi

# Make the installer executable
echo_message "Making the installer executable..."
chmod +x "$INSTALLER_NAME"

# Install Miniconda silently
echo_message "Installing Miniconda to $INSTALL_DIR..."
./"$INSTALLER_NAME" -b -u -p "$INSTALL_DIR"
if [[ $? -ne 0 ]]; then
    echo "Error: Miniconda installation failed."
    exit 1
fi

# Initialize Conda
echo_message "Initializing Conda..."
"$INSTALL_DIR/bin/conda" init zsh