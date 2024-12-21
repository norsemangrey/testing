#!/bin/bash

# Set external logger- and error handling script paths
externalLogger="./utils/logging-and-output-function.sh"
externalErrorHandler="./utils/error-handling-function.sh"

# Source external logger and error handler (but allow execution without them)
source "${externalErrorHandler}" "Test script failed" || true
source "${externalLogger}" || true

# Verify if logger function exists or sett fallback
if [[ $(type -t logMessage) != function ]]; then

    # Fallback minimalistic logger function
    logMessage() {

        local level="${2:-INFO}"
        echo "[$level] $1"

    }

fi

unset debug

# Redirect output functions if not debug enabled
execCommand() {

    if $debug; then
        echo "DEBUG ENABLED"
        "$@"

    else
        echo "DEBUG DISABLED"
        "$@" > /dev/null

    fi

}

# Ensure the system is up-to-date
logMessage "Updating and upgrading the system..." "INFO"

sudo apt-get update -y > /dev/null && sudo apt-get upgrade -y > /dev/null

logMessage "System update and upgrade completed." "INFO"

# Check and install UFW
if ! command -v ufw &> /dev/null; then

    logMessage "Installing UFW..." "INFO"

    # Install JQuery
    sudo apt-get install -y ufw

    logMessage "UFW installed successfully." "INFO"

else

    logMessage "UFW is already installed." "DEBUG"

fi

# Check and install ZSH
if ! command -v zsh &> /dev/null; then

    logMessage "Installing ZSH..." "INFO"

    # Installing ZSH
    sudo apt-get install -y zsh

    logMessage "ZSH installed successfully." "INFO"

else

    logMessage "ZSH is already installed." "DEBUG"

fi

# Check and install Oh-My-Posh
if ! command -v oh-my-posh &> /dev/null; then

    logMessage "Installing Oh-My-Posh..." "INFO"

    # Download Oh-My-Posh
    sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh

    # Set execution permission
    sudo chmod +x /usr/local/bin/oh-my-posh

    logMessage "Oh-My-Posh installed successfully." "INFO"

else

    logMessage "Oh-My-Posh is already installed." "DEBUG"

    sudo oh-my-posh upgrade

fi

# Check and install LSDeluxe (lsd)
if ! command -v lsd &> /dev/null; then

    logMessage "Installing LSDeluxe (lsd)..." "INFO"

    # Install LSDelux
    sudo apt-get install -y lsd

    logMessage "LSDeluxe installed successfully." "INFO"

else

    logMessage "LSDeluxe is already installed." "DEBUG"

fi

# Check and install Fastfetch
if ! command -v fastfetch &> /dev/null; then

    logMessage "Installing Fastfetch..." "INFO"

    # Add repository, update and install Fastfetch
    sudo add-apt-get-repository -y ppa:zhangsongcui3371/fastfetch
    sudo apt-get update
    sudo apt-get install -y fastfetch

    logMessage "Fastfetch installed successfully." "INFO"

else

    logMessage "Fastfetch is already installed." "DEBUG"

fi

# Check and install JQuery (jq)
if ! command -v jq &> /dev/null; then

    logMessage "Installing JQuery (jq)..." "INFO"

    # Install JQuery
    sudo apt-get install -y jq

    logMessage "JQuery installed successfully." "INFO"

else

    logMessage "JQuery is already installed." "DEBUG"

fi

# Set ZSH as the default shell if ZSH environment file exists
if [[ -f "$HOME/.zshenv" ]]; then

    # Check that ZSH is not already default shell
    if [[ "$SHELL" != "$(which zsh)" ]]; then

        logMessage "Setting ZSH as the default shell..." "INFO"

        # Set ZSH as the default shell
        chsh -s "$(which zsh)"

        logMessage "ZSH is now the default shell. Please log out and log back in for changes to take effect." "INFO"

    else

        logMessage "ZSH is already the default shell." "DEBUG"

    fi

else

    logMessage "No ZSH environment file found. Skipping setting ZSH as the default shell." "WARNING"

fi

# Set external SSH installer script
sshInstaller="./ssh-setup-and-config.sh"

# Execute external SSH setup script
if [[ -f "${sshInstaller}" ]]; then

    logMessage "Set execute permissions on installer script (${sshInstaller})." "DEBUG"

    # Set permissions on the installer script
    chmod +x "${sshInstaller}"

    logMessage "Executing SSH setup script (${sshInstaller})..." "INFO"

    # Execute SSH installer
    "${sshInstaller}"

    # Check for errors
    if [[ $? -eq 0 ]]; then

        logMessage "SSH setup script executed successfully." "INFO"

    else

        logMessage "SSH setup script failed." "ERROR"

    fi

else

    logMessage "SSH setup script ($sshInstaller) is not executable or not found." "ERROR"

fi

# Clone and execute install-linux.sh from GitHub repository
dotfilesRepo="https://github.com/norsemangrey/.dotfiles.git"
dotfilesDirectory="$HOME/.dotfiles"
dotfilesInstaller="${dotfilesDirectory}/install-linux.sh"

# Check if the repository already exists
if [[ ! -d "${dotfilesDirectory}" ]]; then

    logMessage "Cloning the .dotfiles repository (${dotfilesRepo})..." "INFO"

    # Clone dotfiles directory
    execCommand git clone "${dotfilesRepo}" "${dotfilesDirectory}"

    # Check for errors
    if [[ $? -ne 0 ]]; then

        logMessage "Failed to clone the .dotfiles repository." "ERROR"

    fi

    logMessage "Successfully cloned .dotfiles repository." "INFO"

else

    logMessage "The .dotfiles repository already exists. Attempting to update..." "DEBUG"

    # Pull latest
    execCommand git -C "${dotfilesDirectory}" pull

    # Check for errors
    if [[ $? -ne 0 ]]; then

        logMessage "Failed to update the .dotfiles repository." "WARNING"

    fi

    logMessage "Successfully updated the .dotfiles repository." "INFO"

fi

# Ensure the install script is executable
if [[ -f "${dotfilesInstaller}" ]]; then

    logMessage "Set execute permissions on installer script (${dotfilesInstaller})." "DEBUG"

    # Set permissions on the installer script
    chmod +x "${dotfilesInstaller}"

    logMessage "Executing .dotfiles installer script (${dotfilesInstaller})..." "INFO"

    # Execute the install script
    "${dotfilesInstaller}"

    # Check for errors
    if [[ $? -eq 0 ]]; then

        logMessage "Install script executed successfully." "INFO"

    else

        logMessage "Install script execution failed." "ERROR"

    fi

else

    logMessage "Install script (${dotfilesInstaller}) not found in the repository." "ERROR"

fi

logMessage "Installer script completed."