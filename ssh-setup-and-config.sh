#!/bin/bash

# Set external logger- and error handling script paths
externalLogger="./logging-and-output-function.sh"
externalErrorHandler="./error-handling-function.sh"

# Source external logger and error handler (but allow execution without them)
source "${externalErrorHandler}" "Failed to set up SSH" || true
source "${externalLogger}" || true

# Verify if logger function exists or sett fallback
if [[ $(type -t logMessage) != function ]]; then

    # Fallback minimalistic logger function
    logMessage() {

        local level="${2:-INFO}"
        echo "[${level}] $1"

    }

fi


# Get the username from the $USER environment variable
username="${USER}"

# Get the IP address of the server
serverIp=$(hostname -I | awk '{print $1}')

# If the username is "root", ask for confirmation before continuing
if [ "${username}" == "root" ]; then

    # Prompt user for confirmation to continue
    read -p "You are logged in as root. Are you sure you want to continue? (y/n): " confirmation

    # If not "Yes" the abort script
    if [[ ! "${confirmation}" =~ ^[Yy]$ ]]; then

        logMessage "Aborted by user. Exiting setup..." "INFO"

        exit 0

    fi

fi

# Check if OpenSSH server is installed
if dpkg -l | grep -q openssh-server; then

    logMessage "OpenSSH server is already installed." "DEBUG"

else

    logMessage "Installing OpenSSH server..." "INFO"

    # Update and install OpenSSH server
    sudo apt-get update && sudo apt-get install -y openssh-server

fi

# Check if SSH service is already running
if ! systemctl is-active --quiet ssh; then

    logMessage "Starting and enabling SSH service..." "INFO"

    # Start and enable the SSH service
    sudo systemctl start ssh
    sudo systemctl enable ssh

else

    logMessage "SSH service is already running." "DEBUG"

fi

# Check if UFW is installed and SSH rule exists
if command -v ufw >/dev/null; then

    logMessage "Checking firewall rules..." "DEBUG"

    # Check if SSH firewall rule is already configured
    if sudo ufw show added | grep -q ' 22/tcp'; then

        logMessage "Firewall rule for SSH already exists." "DEBUG"

    else

        logMessage "Configuring firewall to allow SSH..." "INFO"

        # Set allow rule for SSH on port 22 and reload UFW
        sudo ufw allow 22/tcp comment 'SSH'
        sudo ufw reload

    fi

else

    echo "UFW is not installed. Skipping firewall configuration." "WARNING"

fi

logMessage "Setting up SSH key-based authentication for '${username}'..." "INFO"

# Create SSH directory if it doesn't exist and set correct permissions
if [ ! -d "/home/${username}/.ssh" ]; then

    # Create directory and set correct permissions
    sudo mkdir -p /home/"${username}"/.ssh
    sudo chmod 700 /home/"${username}"/.ssh

fi

# Create authorized_keys file if it doesn't exist
if [ ! -f /home/"${username}"/.ssh/authorized_keys ]; then

    echo "Creating the authorized keys file..." "INFO"

    # Create file and set correct permissions
    sudo touch /home/"${username}"/.ssh/authorized_keys
    sudo chmod 600 /home/"${username}"/.ssh/authorized_keys

fi

# Track the initial line count of the authorized_keys file
initialKeyCount=$(wc -l < /home/"${username}"/.ssh/authorized_keys 2>/dev/null || echo 0)

# Loop to check and prompt for the public key until it is found in the authorized_keys file
while true; do

    # Prompt user to copy the public key from the client computer
    echo "Please use the 'ssh-copy-id' command from your client machine to copy your public key to this server."
    echo "Example: ssh-copy-id ${username}@${serverIp}"
    read -p "Press Enter after copying the public key to continue..." 2>&1

    # Get the current line count
    currentKeyCount=$(wc -l < /home/"${username}"/.ssh/authorized_keys 2>/dev/null || echo 0)

    # Check for new line and validate new key
    if [ "${currentKeyCount}" -gt "${initialKeyCount}" ] && tail -n 1 /home/"${username}"/.ssh/authorized_keys | grep -q "^ssh-"; then

        logMessage "Client public key successfully added." "INFO"

        break

    else

        logMessage "Public key not found in the authorized keys file." "WARNING"

        # Prompt user for retry
        echo "Please ensure that the public key has been copied correctly."
        read -p "Press 'Enter' to retry..." 2>&1

    fi

done

logMessage "Backing up existing SSH config and configuring to disable root login and password authentication..."

# Backup existing SSH configuration
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
sshConfigBackup="/etc/ssh/sshd_config.bak.${timestamp}"
sudo cp /etc/ssh/sshd_config "${sshConfigBackup}"

# Check and update SSH configuration values only if necessary
sshConfigUpdate() {

    local setting="${1}"
    local value="${2}"

    if ! sudo grep -q "^${setting} ${value}" /etc/ssh/sshd_config; then

        sudo sed -i "s/^#${setting}.*/${setting} ${value}/" /etc/ssh/sshd_config
        sudo sed -i "/^${setting} /!a ${setting} ${value}" /etc/ssh/sshd_config

        configUpdated=true

    fi

}

# Modify config to disable root login and password authentication
sshConfigUpdate "PermitRootLogin" "no"
sshConfigUpdate "PasswordAuthentication" "no"
sshConfigUpdate "ChallengeResponseAuthentication" "no"
sshConfigUpdate "UsePAM" "no"

# If config was updated, restart SSH and keep the backup
if [ "${configUpdated}" = true ]; then

    logMessage "SSH configuration updated. Restarting SSH service..." "INFO"

    # Restart SSH service to apply changes
    sudo systemctl restart ssh

else

    logMessage "No changes made to the SSH configuration." "INFO"

    # Remove the backup file if no changes were made
    sudo rm "${sshConfigBackup}"

fi

# Print success message
logMessage "SSH successfully enabled and key-based authentication configured for user '${username}'." "INFO"

echo "You can now log in using the private key corresponding to the provided public key."

exit 0