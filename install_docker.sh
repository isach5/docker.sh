#!/bin/bash
set -e

# Ensure the script is running as root
if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root. Try running with: sudo $0"
  exit 1
fi

echo "Removing any older versions of Docker..."
apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

echo "Updating package index and installing prerequisites..."
apt-get update
apt-get install -y ca-certificates curl gnupg lsb-release

echo "Adding Docker's official GPG key..."
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "Setting up the Docker repository..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
| tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "Updating package index..."
apt-get update

echo "Installing Docker Engine, CLI, Containerd, and Docker Compose plugin..."
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Optionally add a user to the docker group to allow non-root usage
read -p "Enter a username to add to the docker group (or press Enter to skip): " username
if [ -n "$username" ]; then
  if id "$username" &>/dev/null; then
    usermod -aG docker "$username"
    echo "User '$username' has been added to the docker group."
    echo "Log out and log back in for the changes to take effect."
  else
    echo "User '$username' does not exist. Skipping user group modification."
  fi
fi

echo "Docker and Docker Compose have been installed successfully."
