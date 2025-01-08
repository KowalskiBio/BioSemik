#!/bin/bash

# Function to print messages
echo_message() {
    echo -e "\n>>> $1\n"
}

# Check if conda is already installed
if command -v conda &> /dev/null; then
    echo_message "Conda is already installed. Skipping installation."
    exit 0
fi

# Check if curl is installed
if ! command -v curl &> /dev/null; then
    echo "curl is not installed. Attempting to install it..."
    
    # Detect the operating system
    OS=$(uname -s)
    
    if [[ "$OS" == "Darwin" ]]; then
        # macOS
        if command -v brew &> /dev/null; then
            brew install curl
        else
            echo "Error: Homebrew is not installed. Please install Homebrew to proceed."
            exit 1
        fi
    elif [[ "$OS" == "Linux" ]]; then
        # Linux
        if command -v apt &> /dev/null; then
            sudo apt update && sudo apt install -y curl
        elif command -v yum &> /dev/null; then
            sudo yum install -y curl
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y curl
        else
            echo "Error: No compatible package manager found. Please install curl manually."
            exit 1
        fi
    else
        echo "Error: Unsupported operating system. Please install curl manually."
        exit 1
    fi
fi

# Check the operating system
OS=$(uname -s)

# Installation for macOS
if [[ "$OS" == "Darwin" ]]; then
    MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh"
    INSTALLER_NAME="Miniconda3-latest-MacOSX-x86_64.sh"
    INSTALL_DIR="$HOME/.miniconda3"

    # Download Miniconda installer for macOS
    echo_message "Downloading Miniconda installer for macOS..."
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

# Installation for Linux
elif [[ "$OS" == "Linux" ]]; then
    INSTALL_DIR="$HOME/miniconda3"
    
    # Download Miniconda installer for Linux
    echo_message "Downloading Miniconda installer for Linux..."
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O "$INSTALL_DIR/miniconda.sh"
    if [[ ! -f "$INSTALL_DIR/miniconda.sh" ]]; then
        echo "Error: Failed to download Miniconda installer."
        exit 1
    fi

    # Install Miniconda silently
    echo_message "Installing Miniconda to $INSTALL_DIR..."
    bash "$INSTALL_DIR/miniconda.sh" -b -u -p "$INSTALL_DIR"
    if [[ $? -ne 0 ]]; then
        echo "Error: Miniconda installation failed."
        exit 1
    fi

    # Remove installer
    rm "$INSTALL_DIR/miniconda.sh"

# Installation for Windows (PowerShell)
elif [[ "$OS" == "MINGW32_NT" || "$OS" == "MINGW64_NT" ]]; then
    # Check if running in Windows
    echo_message "Detected Windows, using PowerShell script for installation."

    # Download Miniconda installer for Windows
    curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe -o miniconda.exe
    if [[ ! -f "miniconda.exe" ]]; then
        echo "Error: Failed to download Miniconda installer."
        exit 1
    fi

    # Run Miniconda installer
    echo_message "Installing Miniconda on Windows..."
    powershell.exe Start-Process -FilePath ".\miniconda.exe" -ArgumentList "/S" -Wait

    # Remove installer
    del miniconda.exe

else
    echo "Error: Unsupported operating system. Miniconda installation is supported only on macOS, Linux, and Windows."
    exit 1
fi

rm -rf Miniconda3-latest-*