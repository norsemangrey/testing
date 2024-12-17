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

# Update package list and install OpenSSH if not already installed
echo "Installing OpenSSH server..."
sudo apt update
sudo apt install -y openssh-server

# Start and enable SSH service
echo "Starting and enabling SSH service..."
sudo systemctl start ssh
sudo systemctl enable ssh

# Allow SSH traffic through the firewall (if UFW is enabled)
echo "Configuring firewall to allow SSH..."
sudo ufw allow ssh
sudo ufw reload

# Get the IP address of the server
SERVER_IP=$(hostname -I | awk '{print $1}')

# Create .ssh directory if it doesn't exist and set correct permissions
echo "Setting up SSH key-based authentication for '$USERNAME'..."
sudo mkdir -p /home/"$USERNAME"/.ssh
sudo chmod 700 /home/"$USERNAME"/.ssh

# Ask the user to use ssh-copy-id to copy the public key
echo "Please use the 'ssh-copy-id' command from your client machine to copy your public key to this server."
echo "Example: ssh-copy-id $USERNAME@$SERVER_IP"
echo "Once you've done that, press Enter to continue."
read -p "Press Enter after copying the public key..."

# Verify if the public key exists in the authorized_keys file (checking for any SSH key type)
if ! sudo grep -q "^ssh-" /home/"$USERNAME"/.ssh/authorized_keys; then
  echo "Error: Public key not found in the authorized_keys file."
  echo "Please try again with 'ssh-copy-id'."
  exit 1
fi

# Set correct permissions for the authorized_keys file
sudo chmod 600 /home/"$USERNAME"/.ssh/authorized_keys
sudo chown -R "$USERNAME":"$USERNAME" /home/"$USERNAME"/.ssh

# Modify SSH configuration to disable root login and password authentication
echo "Configuring SSH to disable root login and password authentication..."
sudo sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config

# Restart SSH service to apply changes
echo "Restarting SSH service..."
sudo systemctl restart ssh

# Print success message
echo "SSH key-based authentication is now set up for user '$USERNAME'."
echo "You can now log in using the private key corresponding to the provided public key."