#!/bin/bash

# Exit if any command fails
set -e

# Check and install Zsh
if ! command -v zsh &> /dev/null; then
    echo "Installing Zsh..."
    sudo apt update
    sudo apt install -y zsh
    echo "Zsh installed successfully."
else
    echo "Zsh is already installed."
fi

# Check and install Oh-My-Posh
if ! command -v oh-my-posh &> /dev/null; then
    echo "Installing Oh-My-Posh..."
    sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
    sudo chmod +x /usr/local/bin/oh-my-posh
    echo "Oh-My-Posh installed successfully."
else
    echo "Oh-My-Posh is already installed."
fi

# Check and install LSDeluxe (lsd)
if ! command -v lsd &> /dev/null; then
    echo "Installing LSDeluxe (lsd)..."
    sudo apt install -y lsd
    echo "LSDeluxe installed successfully."
else
    echo "LSDeluxe is already installed."
fi

# Check and install fastfetch
if ! command -v fastfetch &> /dev/null; then
    echo "Installing fastfetch..."
    sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch
    sudo apt update
    sudo apt install -y fastfetch
    echo "Fastfetch installed successfully."
else
    echo "Fastfetch is already installed."
fi

# Set Zsh as the default shell if it's not already
if [[ "$SHELL" != "$(which zsh)" ]]; then
    echo "Setting Zsh as the default shell..."
    chsh -s "$(which zsh)"
    echo "Zsh is now the default shell. Please log out and log back in for changes to take effect."
else
    echo "Zsh is already the default shell."
fi

# jq
# ufw

echo "All requested applications are installed and up to date!"