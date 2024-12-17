#!/bin/bash

# Exit on error
set -e

# Get the username from the $USER environment variable
USERNAME="$USER"

# If the username is "root", ask for confirmation before continuing
if [ "$USERNAME" == "root" ]; then
    read -p "You are logged in as root. Are you sure you want to continue? (y/n): " confirmation
    if [[ ! "$confirmation" =~ ^[Yy]$ ]]; then
        echo "Exiting setup."
        exit 1
    fi
fi

# Check if SSH service is already running
if ! systemctl is-active --quiet ssh; then
    echo "Starting and enabling SSH service..."
    sudo systemctl start ssh
    sudo systemctl enable ssh
else
    echo "SSH service is already running."
fi

# Install OpenSSH server if not already installed
echo "Installing OpenSSH server..."
sudo apt-get update
sudo apt-get install -y openssh-server

# Check if UFW is active and configure firewall
if sudo ufw status | grep -q "active"; then
    echo "Configuring firewall to allow SSH..."
    sudo ufw allow ssh
    sudo ufw reload
else
    echo "UFW is not active. Skipping firewall configuration."
fi

# Get the IP address of the server
SERVER_IP=$(hostname -I | awk '{print $1}')

# Create .ssh directory if it doesn't exist and set correct permissions
echo "Setting up SSH key-based authentication for '$USERNAME'..."
sudo mkdir -p /home/"$USERNAME"/.ssh
sudo chmod 700 /home/"$USERNAME"/.ssh

# Create authorized_keys file if it doesn't exist
if [ ! -f /home/"$USERNAME"/.ssh/authorized_keys ]; then
    echo "Creating the authorized_keys file..."
    sudo touch /home/"$USERNAME"/.ssh/authorized_keys
    sudo chmod 600 /home/"$USERNAME"/.ssh/authorized_keys
fi

# Loop to check and prompt for the public key until it is found in the authorized_keys file
while true; do
    echo "Please use the 'ssh-copy-id' command from your client machine to copy your public key to this server."
    echo "Example: ssh-copy-id $USERNAME@$SERVER_IP"
    echo "Once you've done that, press Enter to continue."
    read -p "Press Enter after copying the public key..."

    if sudo grep -q "^ssh-" /home/"$USERNAME"/.ssh/authorized_keys; then
        echo "Public key successfully added."
        break
    else
        echo "Error: Public key not found in the authorized_keys file."
        echo "Please ensure that the public key has been copied correctly."
        read -p "Press Enter to retry..."
    fi
done

# Set correct permissions for the authorized_keys file
sudo chown -R "$USERNAME":"$USERNAME" /home/"$USERNAME"/.ssh
sudo chmod 700 /home/"$USERNAME"/.ssh
sudo chmod 600 /home/"$USERNAME"/.ssh/authorized_keys

# Backup and modify SSH configuration to disable root login and password authentication
echo "Backing up and configuring SSH to disable root login and password authentication..."
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sudo sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^#ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^#UsePAM.*/UsePAM no/' /etc/ssh/sshd_config

# Restart SSH service to apply changes
echo "Restarting SSH service..."
sudo systemctl restart ssh

# Print success message
echo "SSH key-based authentication is now set up for user '$USERNAME'."
echo "You can now log in using the private key corresponding to the provided public key."

exit 0